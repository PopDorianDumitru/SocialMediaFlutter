//import 'package:english_words/english_words.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:provider/provider.dart';
import './domain/person.dart';
import './registerTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
//import './database/data.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
//import './utils/constants.dart';
import 'package:flutter/foundation.dart';

class LogInPage extends StatelessWidget {
  late final Function setPage;
  late final Person currentUser;
  late final Function connectAccount;
  LogInPage(
      {required this.setPage,
      required this.currentUser,
      required this.connectAccount});
  final TextEditingController username = TextEditingController(),
      password = TextEditingController();

  void getPerson(username, password) async {
    print("MADE REQUEST");
    print(await FirebaseMessaging.instance.getToken());
    print(dotenv.get('BASE_URL'));
    var results;
    String? token = await FirebaseMessaging.instance.getToken();
    String realToken = "";
    if (token != null) {
      realToken = token;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      results = await http.post(
          Uri.parse("${dotenv.get("BASE_USER_URL")}login"),
          body: <String, String>{
            "username": username,
            "password": password,
            "fcm_token": realToken,
          });
    } else {
      results = await http.post(
          Uri.parse("${dotenv.get("BASE_USER_URL_ANDROID")}login"),
          body: <String, String>{
            "username": username,
            "password": password,
            "fcm_token": realToken
          });
    }
    if (results.statusCode == 200) {
      Map<String, dynamic> userMap = json.jsonDecode(results.body);
      Person account = Person.fromMap(userMap);
      this.connectAccount(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              registerTextField("Username", false, username),
              registerTextField("Password", true, password),
              ElevatedButton(
                onPressed: () {
                  print(username.text);
                  getPerson(username.text, password.text);
                },
                child: Text("Log in"),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () {
                    setPage(3);
                  },
                  child: Text(
                    "Don't have an account yet? Press here to register",
                    textAlign: TextAlign.center,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
