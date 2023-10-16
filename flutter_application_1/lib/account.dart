import 'package:flutter/material.dart';
import './domain/person.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatelessWidget {
  late final Function setPage;
  late final Function logOutAccout;
  late final Person currentUser;
  AccountPage(
      {required this.setPage,
      required this.currentUser,
      required this.logOutAccout});
  void logoutUser() async {
    if (TargetPlatform.android == defaultTargetPlatform) {
      http.post(Uri.parse('${dotenv.get("BASE_USER_URL_ANDROID")}/logout'),
          body: <String, String>{
            "email": currentUser.getEmail(),
            "fcmToken": (await FirebaseMessaging.instance.getToken())!
          });
    } else {
      http.post(Uri.parse('${dotenv.get("BASE_USER_URL")}/logout'),
          body: <String, String>{
            "email": currentUser.getEmail(),
            "fcmToken": (await FirebaseMessaging.instance.getToken())!
          });
    }
    logOutAccout();
    setPage(0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(currentUser.getName()),
        ElevatedButton(onPressed: logoutUser, child: Text("Log out"))
      ],
    );
  }
}
