import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';

class DespesaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Despesa> _getDespesasRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('despesas')
        .withConverter<Despesa>(
          // Converte de Despesa para Map
          toFirestore: (despesa, _) => despesa.toMap(), 
          // Converte de Map para Despesa
          fromFirestore: (snapshot, _) => Despesa.fromMap(snapshot.data()!, snapshot.id),
        );
  }

  // READ: Retorna um "Stream" (fluxo) de despesas em tempo real
  Stream<List<Despesa>> getDespesas() {
    return _getDespesasRef()
        .orderBy('data', descending: true) // Ordena pela data mais recente
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // CREATE: Adiciona uma nova despesa
  Future<void> addDespesa(Despesa despesa) {
    return _getDespesasRef().add(despesa);
  }

  // UPDATE: Atualiza uma despesa existente
  Future<void> updateDespesa(Despesa despesa) {
    if (despesa.id == null) {
      throw Exception('ID da despesa não pode ser nulo para atualizar');
    }
    return _getDespesasRef().doc(despesa.id).update(despesa.toMap());
  }

  // DELETE: Exclui uma despesa
  Future<void> deleteDespesa(String despesaId) {
    return _getDespesasRef().doc(despesaId).delete();
  }
}