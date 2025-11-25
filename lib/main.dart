import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ride_buddy_flutter/screens/login_screen.dart';
import 'package:ride_buddy_flutter/screens/home_screen.dart';
import 'package:ride_buddy_flutter/screens/onboarding_screen.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      // uso do o AuthWrapper ao invés do Streambuilder
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return FutureBuilder<UserProfile>( // Especificamos o tipo aqui
            future: UserService().getUserProfile(), 
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
              }

              // Verifica o status do perfil
              if (profileSnapshot.hasData) {
                final userProfile = profileSnapshot.data!;
                
                // NOVO CRITÉRIO: Permite acesso se o setup está completo OU se já tiver nome cadastrado (usuário antigo)
                final bool isLegacyUserComplete = userProfile.nome.isNotEmpty || userProfile.modeloVeiculo.isNotEmpty;
                
                if (userProfile.isSetupComplete || isLegacyUserComplete) {
                  return const HomeScreen(); // Tudo certo, vai pra Home
                } else {
                  return const OnboardingScreen(); // Falta cadastro, vai pro Wizard
                }
              }

              // Fallback (se o profileSnapshot der erro, vai para o onboarding por segurança)
              return const OnboardingScreen();
            },
          );
        }

        // Se não tem usuário, Login
        return const LoginScreen();
      },
    );
  }
}