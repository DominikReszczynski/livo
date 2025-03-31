import 'package:cas_house/services/dashboard_services.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _count = 0;
  String _chatText = "";
  bool _loadingChat = false;

  int get count => _count;
  String get chatText => _chatText;
  bool get loadingChat => _loadingChat;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void chat() async {
    ChangeChatLoading();
    final String result = await DashboardServices().chat();
    print(result);
    _chatText = result;
    ChangeChatLoading();
    notifyListeners();
  }

  void ChangeChatLoading() {
    _loadingChat = !loadingChat;
    notifyListeners();
  }
}
