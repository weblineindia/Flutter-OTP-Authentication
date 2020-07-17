import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Phone Verification successful!',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
