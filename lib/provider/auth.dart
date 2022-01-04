import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> authentication(
      String email, String password, String urlSegmant) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegmant?key=AIzaSyDTd4tslTdTgb0z4DOtfFG5_prT83QZxD0';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error1'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _userId = responseData['localId'];
      _token = responseData['idToken'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
    autoLogout();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'token': _token,
        'userID': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      },
    );
    prefs.setString('userData', userData);
  }

  Future<void> signUp(String email, String password) async {
    return authentication(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return authentication(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async{
    final prefs= await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate =DateTime.parse(extractedUserData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token=extractedUserData['token'];
    _userId = extractedUserData['userID'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;

  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _authTimer = null;
    notifyListeners();
    final prefs =await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpire), () => logout());
  }
}
