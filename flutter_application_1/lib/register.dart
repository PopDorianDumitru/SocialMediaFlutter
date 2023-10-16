// import 'dart:js';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:dbcrypt/dbcrypt.dart';
//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/domain/person.dart';
//import 'package:provider/provider.dart';
import './registerTextField.dart';
//import 'package:mongo_dart/mongo_dart.dart';
//import "./database/data.dart";
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'package:flutter/foundation.dart';

class RegisterPage extends StatelessWidget {
  late final Function setPage;
  late final Person currentUser;
  late final Function connectAccount;
  RegisterPage(
      {required this.setPage,
      required this.currentUser,
      required this.connectAccount});

  final TextEditingController email = TextEditingController(),
      password = TextEditingController(),
      username = TextEditingController(),
      cPassword = TextEditingController(),
      name = TextEditingController();
  void registerUser(context) async {
    if (email.text.isEmpty ||
        username.text.isEmpty ||
        password.text.isEmpty ||
        cPassword.text.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Please complete every label"),
            );
          });
    } else {
      var result;
      String? token = await FirebaseMessaging.instance.getToken();
      String realToken = "";
      if (token != null) {
        realToken = token;
      }
      if (defaultTargetPlatform == TargetPlatform.windows) {
        result = await http.post(
            Uri.parse("${dotenv.get("BASE_USER_URL")}register"),
            body: <String, String>{
              "username": username.text,
              "password": password.text,
              "email": email.text,
              "name": name.text,
              "fcm_token": realToken,
            });
      } else {
        result = await http.post(
            Uri.parse("${dotenv.get("BASE_USER_URL_ANDROID")}register"),
            body: <String, String>{
              "username": username.text,
              "password": password.text,
              "email": email.text,
              "name": name.text,
              "fcm_token": realToken
            });
      }
      if (result.statusCode == 409) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content:
                    Text("Either the uesrname or the email is already in use"),
              );
            });
      } else if (result.statusCode == 500) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Server error, please try again"),
              );
            });
      } else {
        Map<String, dynamic> userMap = json.jsonDecode(result.body);
        Person account = Person.fromMap(userMap);
        connectAccount(account);
      }
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
              registerTextField("Email", false, email),
              registerTextField("Username", false, username),
              registerTextField("Name", false, name),
              registerTextField("Password", true, password),
              registerTextField("Confirm Password", true, cPassword),
              ElevatedButton(
                onPressed: () {
                  if (password.text != cPassword.text) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("The passwords don't match!"),
                          );
                        });
                    cPassword.clear();
                  } else {
                    registerUser(context);
                  }
                },
                child: Text("Register"),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () {
                    setPage(1);
                  },
                  child: Text(
                    "Already have an account? Log in",
                    textAlign: TextAlign.center,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
