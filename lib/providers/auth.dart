//import 'dart:convert';

import 'dart:convert';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
//import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if ((_expiryDate != null) &&
        (_expiryDate.isAfter(DateTime.now())) &&
        (_token != null)) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String _email, String _password, String _urlsegment) async {
    final _uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$_urlsegment?key=AIzaSyC8ySS6Z7KATOmeOiDBMgnrmXy2coNXEdw');
    try {
      final response = await http.post(_uri,
          body: json.encode({
            'email': _email,
            'password': _password,
            'returnSecureToken': true,
          }));
      // print("post DONE");
      //print(response.statusCode);
      //print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(
          (responseData['expiresIn']),
        ),
      ));
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      // print('\n userId {$_userId} \n expire {$_expiryDate} \n token {$_token}');
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signIn(String _email, String _password) async {
    /* print(' index email {$_email} and Password {$_password}');
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then(
            (_) => Navigator.of(context).pushReplacementNamed('/prodsOverview'))
        .catchError((error) {
      print('Error Occurred ${error.toString()}');
    }); */
    return _authenticate(_email, _password, 'signInWithPassword');
  }

  Future<void> signup(String _email, String _password) async {
    return _authenticate(_email, _password, 'signUp');
    //print("email {$_email}, password {$_password}");
    //final _uri = Uri.parse(
    //  'identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyC8ySS6Z7KATOmeOiDBMgnrmXy2coNXEdw');
    //print('object');

    /* FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password)
        .then((_) => Navigator.pushReplacementNamed(context, '/auth'))
        .catchError((_) {
      print('eRROR oCCURED');
    }); */
  }
}
