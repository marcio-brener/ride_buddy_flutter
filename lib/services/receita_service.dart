import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/receita.dart';

class ReceitaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Receita> _getReceitasRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return _firestore
            .collection('users')
            .doc(user.uid)
            .collection('receitas')
            .withConverter<Receita>(
              toFirestore: (receita, _) => receita.toMap(),
              fromFirestore: (snapshot, _) => Receita.fromMap(snapshot.data()!, snapshot.id),
            );
  }

  // READ 
  Stream<List<Receita>> getReceitas() {
    return _getReceitasRef()
            .orderBy('dataHora', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ADICIONAR RECEITA
  Future<void> addReceita(Receita receita) {
    return _getReceitasRef().add(receita);
  }

  // UPDATE
  Future<void> updateReceita(Receita receita) {
    if (receita.id == null) {
      throw Exception('ID da receita não pode ser nulo para atualizar');
    } 
    return _getReceitasRef().doc(receita.id).update(receita.toMap());
  }

  // DELETE
  Future<void> deletaReceita(String receitaId) {
    return _getReceitasRef().doc(receitaId).delete();
  }

}