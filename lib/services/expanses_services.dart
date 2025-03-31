import 'dart:convert';

import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/expanses.dart';
import 'package:http/http.dart' as http;

class ExpansesServices {
  final String _urlPrefix = ApiService.baseUrl;

  addExpanse(Expanses expanse) async {
    print('test');
    Map<String, dynamic> body = {
      'expanse': expanse,
    };
    print(_urlPrefix);
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/expanse/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.toString());
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print(decodedBody);
    if (decodedBody['success']) {
      Expanses expanse = Expanses.fromJson(decodedBody['expanse']);
      return expanse;
    }
  }

  getAllExpansesByAuthor() async {
    print('test getExpansesByAuthor');
    Map<String, dynamic> body = {
      'authorId': loggedUser!.id,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/expanse/getAnyExpansesByUserId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print("decodebody" + decodedBody['expanses'].toString());
    if (decodedBody['success']) {
      List<Expanses> expanses =
          (decodedBody['expanses'] as List<dynamic>).map((item) {
        return Expanses.fromJson(item);
      }).toList();
      return expanses;
    }
  }

  getAllExpansesByAuthorExcludingCurrentMonth() async {
    print('test getExpansesByAuthor');
    Map<String, dynamic> body = {
      'authorId': loggedUser!.id,
    };
    final http.Response res = await http.post(
      Uri.parse(
          '$_urlPrefix/expanse/getAllExpansesByAuthorExcludingCurrentMonth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> decodedBody = json.decode(res.body);
    // print("decodebody" + decodedBody.toString());
    if (decodedBody['success']) {
      // List<Expanses> expanses = decodedBody['groupedExpanses'].map((item) {
      //   return Expanses.fromJson(item);
      // }).toList();
      return decodedBody['groupedExpanses'];
    }
  }

  getExpansesByAuthorForCurrentMonth() async {
    print('test getExpansesByAuthor');
    Map<String, dynamic> body = {
      'authorId': loggedUser!.id,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/expanse/getExpansesByAuthorForCurrentMonth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print("decodebody" + decodedBody['expanses'].toString());
    if (decodedBody['success']) {
      List<Expanses> expanses =
          (decodedBody['expanses'] as List<dynamic>).map((item) {
        return Expanses.fromJson(item);
      }).toList();
      return expanses;
    }
  }

  getExpensesGroupedByCategory(String date, String userId) async {
    print('test getExpensesGroupedByCategory');

    Map<String, dynamic> body = {
      'authorId': loggedUser!.id,
      'monthYear': date, //2024-12
    };

    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/expanse/getExpensesGroupedByCategory'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    Map<String, dynamic> decodedBody = json.decode(res.body);
    // print("decodebody" + decodedBody['expanses'].toString());
    if (decodedBody['success']) {
      return decodedBody['groupedByCategory'];
    }
  }

  removeExpanse(String expanseId) async {
    print(1);
    Map<String, dynamic> body = {
      'expanseId': expanseId,
    };
    print(2);
    final http.Response res = await http.delete(
      Uri.parse('$_urlPrefix/expanse/removeExpanse'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(3);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print(decodedBody);
    if (decodedBody['success']) {
      return true;
    } else {
      return false;
    }
  }
}
