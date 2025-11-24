import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Recuperação do objeto UserProfile do Firestore.
  Future<UserProfile> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Usuário não logado");

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, uid);
    } else {
      // Retorna perfil vazio para forçar o onboarding se isSetupComplete for false
      return UserProfile.empty(uid);
    }
  }

  /// Persistência do objeto UserProfile no Firestore.
  Future<void> saveUserProfile(UserProfile profile) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Usuário não logado");

    // Uso de SetOptions(merge: true) para evitar a exclusão de subcoleções (receitas/despesas)
    await _firestore.collection('users').doc(uid).set(
      profile.toMap(),
      SetOptions(merge: true), 
    );
  }
}