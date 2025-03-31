import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/services/expanses_services.dart';
import 'package:flutter/material.dart';

class PropertiesProvider extends ChangeNotifier {
  List<Expanses> _expansesListThisMounth = [];

  List<Expanses> get expansesListThisMounth => _expansesListThisMounth;

  List<dynamic> _expansesListHistory = [];

  List<dynamic> get expansesListHistory => _expansesListHistory;

  Future<void> fetchExpensesForCurrentMonth() async {
    try {
      final List<Expanses>? result =
          await ExpansesServices().getExpansesByAuthorForCurrentMonth();
      if (result != null) {
        _expansesListThisMounth = result;
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future fetchExpensesGroupedByCategory(String date, String userId) async {
    try {
      final Map<String, dynamic>? result =
          await ExpansesServices().getExpensesGroupedByCategory(date, userId);
      return result;
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchExpansesByAuthorExcludingCurrentMonth() async {
    try {
      final List<dynamic>? result = await ExpansesServices()
          .getAllExpansesByAuthorExcludingCurrentMonth();

      if (result != null) {
        result.map((item) =>
            item['expanses'].map((expanses) => Expanses.fromJson(expanses)));
        _expansesListHistory = result;
        notifyListeners();
        print(expansesListHistory);
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }

  Future<void> fetchExpenses() async {
    try {
      final List<dynamic>? result =
          await ExpansesServices().getAllExpansesByAuthor();
      if (result != null) {
        _expansesListHistory = result;
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> addExpense(Expanses newExpense) async {
    try {
      final result = await ExpansesServices().addExpanse(newExpense);
      if (result != null) {
        _expansesListThisMounth.insert(0, result);
        notifyListeners();
      }
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  Future<void> removeExpense(String expanseId) async {
    try {
      final result = await ExpansesServices().removeExpanse(expanseId);
      if (result == true) {
        var index = expansesListThisMounth
            .indexWhere((expanse) => expanseId == expanse.id);
        _expansesListThisMounth.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print("Error removed expense: $e");
    }
  }
}
