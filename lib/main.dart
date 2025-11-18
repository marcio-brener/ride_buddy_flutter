import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ride_buddy_flutter/screens/login_screen.dart';
import 'package:ride_buddy_flutter/screens/home_screen.dart';
import 'package:ride_buddy_flutter/screens/onboarding_screen.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';

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

// --- PORTEIRO ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Carregando Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Se tem usuário logado, verifica o perfil
        if (snapshot.hasData) {
          return FutureBuilder(
            future: UserService().getUserProfile(), // Busca o perfil
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                // Tela de carregamento enquanto verifica o perfil
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
              }

              // 3. Verificação se o cadastro está completo
              if (profileSnapshot.hasData) {
                final userProfile = profileSnapshot.data!;

                // Adicionamos um critério para usuários LEGACY:
                final bool isLegacyUserComplete = userProfile.nome.isNotEmpty || userProfile.modeloVeiculo.isNotEmpty;
                
                // Se o setup foi marcado como completo OU se for um usuário antigo com dados:
                if (userProfile.isSetupComplete || isLegacyUserComplete) {
                    return const HomeScreen(); // Tudo certo, vai pra Home
                } else {
                    return const OnboardingScreen(); // Falta cadastro, vai pro Wizard
                }
              }

              // Fallback em caso de erro (tenta ir pro onboarding)
              return const OnboardingScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}