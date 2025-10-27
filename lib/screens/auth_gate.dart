import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/screens/home_screen.dart';
import 'package:ride_buddy_flutter/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // --- DIAGNÓSTICO ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("AUTHGATE: Aguardando conexão com o Firebase...");
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // O usuário ESTÁ logado
          print("AUTHGATE: Usuário detectado (ID: ${snapshot.data!.uid}). Mostrando HomeScreen.");
          return const HomeScreen();
        } else {
          // O usuário NÃO está logado
          print("AUTHGATE: Usuário não detectado (null). Mostrando LoginScreen.");
          return const LoginScreen();
        }
        // --- FIM DIAGNÓSTICO ---
      },
    );
  }
}