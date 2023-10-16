//import 'dart:html';

import 'dart:convert' as json;
//import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/domain/person.dart';
import 'package:provider/provider.dart';
import "./logIn.dart";
import "./register.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'account.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance
      .getToken()
      .then((value) => print("Get token: ${value}"));
  await dotenv.load();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

Future<void> fireBaseHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavourite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(value) {
    favorites.remove(value);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  late SharedPreferences prefs;

  void setPage(int pageIndex) {
    setState(() {
      selectedIndex = pageIndex;
    });
  }

  void checkLogin() async {
    prefs = await SharedPreferences.getInstance();
    var results;
    if (prefs.getString("username") != null) {
      String username = prefs.getString("username")!,
          password = prefs.getString("password")!;
      if (defaultTargetPlatform == TargetPlatform.windows) {
        results = await http.post(
            Uri.parse("${dotenv.get("BASE_USER_URL")}loginPersistent"),
            body: <String, String>{"username": username, "password": password});
      } else {
        results = await http.post(
            Uri.parse("${dotenv.get("BASE_USER_URL_ANDROID")}loginPersistent"),
            body: <String, String>{"username": username, "password": password});
      }
      if (results.statusCode == 200) {
        Map<String, dynamic> userMap = json.jsonDecode(results.body);
        Person account = Person.fromMap(userMap);
        connectAccount(account);
      }
    }
  }

  _MyHomePageState() {
    checkLogin();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setPage(0);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        setPage(0);
      }
    });
    FirebaseMessaging.onBackgroundMessage(fireBaseHandler);
  }

  void connectAccount(Person account) async {
    prefs.setString("username", account.getUserName());
    prefs.setString("password", account.getPasswordHash());
    setState(() {
      accountConnected = true;
      currentUser = account;
    });
  }

  void logoutAccount() async {
    prefs.clear();
    setState(() {
      accountConnected = false;
      currentUser.erase();
      prefs.clear();
    });
  }

  Person currentUser = Person("", "", "", "", "");
  bool accountConnected = false;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(
          currentUser: currentUser,
        );
        break;
      case 1:
        {
          if (accountConnected) {
            page = FavouritesPage(currentUser: currentUser);
          } else {
            page = LogInPage(
                setPage: setPage,
                currentUser: currentUser,
                connectAccount: connectAccount);
          }
          selectedIndex = 1;
          break;
        }
      case 2:
        page = AccountPage(
            setPage: setPage,
            currentUser: currentUser,
            logOutAccout: logoutAccount);

      case 3:
        page = RegisterPage(
            setPage: setPage,
            currentUser: currentUser,
            connectAccount: connectAccount);
        selectedIndex = 1;

        break;
      default:
        throw UnimplementedError("No widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(children: [
          SafeArea(
              child: NavigationRail(
            extended: constraints.maxWidth > 600,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("Home")),
              if (accountConnected)
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text("Favourites")),
              if (!accountConnected)
                NavigationRailDestination(
                    icon: Icon(Icons.login), label: Text("Log in")),
              if (accountConnected)
                NavigationRailDestination(
                    icon: Icon(Icons.person), label: Text("Account"))
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setPage(value);
            },
          )),
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: page,
          ))
        ]),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  late final Person currentUser;
  GeneratorPage({required this.currentUser});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigCard(pair: pair),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Next")),
            SizedBox(
              width: 20,
            ),
            ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                },
                icon: Icon(icon),
                label: Text("Favourite"))
          ],
        )
      ]),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Card(
      color: theme.colorScheme.primary,
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first}${pair.second}",
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  late final Person currentUser;
  FavouritesPage({required this.currentUser});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
