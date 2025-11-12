import 'dart:io';
import 'package:cas_house/services/defect_services.dart';
import 'package:flutter/foundation.dart';

import 'package:cas_house/models/defect.dart';
import 'package:cas_house/providers/user_provider.dart';
import 'package:flutter/scheduler.dart';

class DefectsProvider extends ChangeNotifier {
  final UserProvider userProvider;
  DefectsProvider(this.userProvider);

  // ======== Defects ========
  List<Defect> _defects = [];
  bool _loading = false;
  String? _error;

  List<Defect> get defects => _defects;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> addDefect(Defect defect, List<File> images) async {
    final newDefect = await DefectsService.addDefect(defect, images);
    _defects.add(newDefect);
    notifyListeners();
  }

  void _safeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    // Jeśli jesteśmy już poza fazą build albo w post-frame — można normalnie
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      // Jesteśmy w trakcie build — przesuń powiadomienie na następną klatkę
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> fetchDefects() async {
    _loading = true;
    _error = null;
    _safeNotify();
    try {
      _defects = await DefectsService.getAllDefects();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  Future<void> updateStatus(String defectId, String newStatus) async {
    try {
      final updated =
          await DefectsService.updateDefectStatus(defectId, newStatus);
      if (updated != null) {
        final i = _defects.indexWhere((d) => d.id == defectId);
        if (i != -1) {
          _defects[i] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Błąd aktualizacji statusu: $e');
      rethrow;
    }
  }

  Future<void> fetchForUser(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _defects = await DefectsService().getDefectsByUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ======== Comments ========
  final Map<String, List<Comment>> _commentsByDefect = {};
  final Map<String, bool> _loadingByDefect = {};
  final Map<String, bool> _postingByDefect = {};
  final int pageSize = 50;

  List<Comment> commentsFor(String defectId) =>
      _commentsByDefect[defectId] ?? [];
  bool isLoading(String defectId) => _loadingByDefect[defectId] ?? false;
  bool isPosting(String defectId) => _postingByDefect[defectId] ?? false;

  Future<void> fetchComments(String defectId, {int skip = 0}) async {
    _loadingByDefect[defectId] = true;
    notifyListeners();
    try {
      final items = await DefectsService.fetchComments(
        defectId,
        token: userProvider.token,
        skip: skip,
        limit: pageSize,
      );
      if (skip == 0) {
        _commentsByDefect[defectId] = items;
      } else {
        _commentsByDefect.putIfAbsent(defectId, () => []);
        _commentsByDefect[defectId]!.addAll(items);
      }
    } finally {
      _loadingByDefect[defectId] = false;
      notifyListeners();
    }
  }

  Future<Comment> addComment(
    String defectId,
    String message, {
    List<File> attachments = const [],
  }) async {
    _postingByDefect[defectId] = true;
    notifyListeners();
    try {
      final comment = await DefectsService.addComment(
        defectId,
        message,
        token: userProvider.token,
        attachments: attachments,
      );
      _commentsByDefect.putIfAbsent(defectId, () => []);
      _commentsByDefect[defectId]!.add(comment);
      notifyListeners();
      return comment;
    } finally {
      _postingByDefect[defectId] = false;
      notifyListeners();
    }
  }

  // pomocnicze
  void clearComments(String defectId) {
    _commentsByDefect.remove(defectId);
    _loadingByDefect.remove(defectId);
    _postingByDefect.remove(defectId);
    notifyListeners();
  }

  void clearAll() {
    _defects = [];
    _error = null;
    _commentsByDefect.clear();
    _loadingByDefect.clear();
    _postingByDefect.clear();
    notifyListeners();
  }
}
