import 'package:flutter/material.dart';
import '/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 90, left: 20, right: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo_ride.png",
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  Text(
                    "RideBuddy",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),
                  LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
