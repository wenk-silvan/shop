import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:flutter_complete_guide/secret-loader.dart';
import 'package:flutter_complete_guide/secret.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return this.token != null;
  }

  String get token {
    if (this._expiryDate != null &&
        this._expiryDate.isAfter(DateTime.now()) &&
        this._token != null) {
      return this._token;
    }
    return null;
  }

  String get userId {
    return this._userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      Future<Secret> secret = SecretLoader(secretPath: "secrets.json").load();
      await secret.then((secret) async {
        final url =
            'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=${secret.apiKey}';
        final response = await http.post(url,
            body: json.encode({
              'email': email,
              'password': password,
              'returnSecureToken': true,
            }));
        final responseData = json.decode(response.body);
        print(responseData);
        if (responseData['error'] != null) {
          throw HttpException(responseData['error']['message']);
        }
        this._token = responseData['idToken'];
        this._userId = responseData['localId'];
        this._expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      });
      this.notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return this._authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signup(String email, String password) async {
    return this._authenticate(email, password, 'signUp');
  }
}
