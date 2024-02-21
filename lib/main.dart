import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen/home_screen.dart';
import 'screens/login_screen/login_screen.dart';
import 'screens/otp_screen/otp_screen.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Platform.isAndroid
        ? await Firebase.initializeApp(
            options: const FirebaseOptions(
                apiKey: 'xxxxxxxxxxxx-g-famDgC3jx6VV4h-xxxxxx',
                appId: '1:xxxxxxxxxxxx:android:xxxxxxxb7ea052854b0005',
                messagingSenderId: 'xxxxxxxxxxxx',
                projectId: 'flutterxxxxxxxxx-9xxxa'))
        : await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter OTP Authentication',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 253, 188, 51),
      ),
      home: LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/otpScreen': (BuildContext ctx) => OtpScreen(),
        '/homeScreen': (BuildContext ctx) => HomeScreen(),
      },
    );
  }
}
