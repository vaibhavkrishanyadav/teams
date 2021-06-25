import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teams/screens/home.dart';
import 'package:teams/screens/home_screen.dart';
import 'package:teams/screens/loginScreen.dart';
import 'package:teams/utils/firebase_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseRepo _repo = FirebaseRepo();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      // home: FutureBuilder(
      //     future: _repo.getCurrentUser(),
      //     builder: (context, AsyncSnapshot<User> snapshot) {
      //       if (snapshot.hasData) {
      //         return Home();
      //       } else {
      //         return LoginScreen();
      //       }
      //     }),
    );
  }
}
