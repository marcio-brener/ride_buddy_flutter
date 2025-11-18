import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  // Busca os dados do perfil
  Future<UserProfile> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Usuário não logado");

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, uid);
    } else {
      return UserProfile.empty(uid);
    }
  }

  // Salva/Atualiza os dados
  Future<void> saveUserProfile(UserProfile profile) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("Usuário não logado");

    // Usamos merge: true para não apagar subcoleções (despesas/receitas)
    await _firestore.collection('users').doc(uid).set(
      profile.toMap(),
      SetOptions(merge: true), 
    );
  }
}