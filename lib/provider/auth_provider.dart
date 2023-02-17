import 'dart:convert';

import 'package:agora_live_streaming/utils/constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final authProvider =
    ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;

  String? get token => _token;
  String? get userId => _userId;

  Future<void> userLogin(String email, String password) async {
    const url = LOG_IN_USER;

    final header = {'Content-Type': 'application/json'};
    final body = {"email": email, "password": password};

    try {
      final response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(body));
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['status']) {
        _token = responseData['data']['token'];
        _userId = responseData['data']['user']['id'];
        print(_token);
        notifyListeners();
      }
      // print(json.decode(response.body));
    } catch (e) {
      print("XXXXXXXXXXX $e");
    }
  }
}
