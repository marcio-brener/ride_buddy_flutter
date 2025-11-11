import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/relatorio.dart';

class RelatorioService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- Funções principais ---

  /// Busca todos os dados e calcula o relatório para um mês específico
  Future<Relatorio> getRelatorioMensal(DateTime mes) async {
    
    final userId = _userId;

    print("RELATORIO_SERVICE: Tentando buscar dados para o User ID: $userId");
    
    if (userId == null) throw Exception("Usuário não logado");



    // 1. Define o início e o fim do mês
    final inicioMes = DateTime(mes.year, mes.month, 1);
    final fimMes = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);

    // 2. Cria as três buscas (Futures) que rodarão em paralelo
    final metaFuture = _getMeta(userId);
    
    final totalReceitasFuture = _getTotalReceitasDoMes(userId, inicioMes, fimMes);
    final totalDespesasFuture = _getTotalDespesasDoMes(userId, inicioMes, fimMes);

    // 3. Espera todas as buscas terminarem
    final results = await Future.wait([
      metaFuture,
      totalReceitasFuture,
      totalDespesasFuture,
    ]);

    // 4. Processa os resultados
    final double meta = results[0];
    final double totalReceitas = results[1];
    final double totalDespesas = results[2];

    // 5. Retorna o objeto Relatorio completo
    return Relatorio(
      totalReceitas: totalReceitas,
      totalDespesas: totalDespesas,
      meta: meta,
    );
  }
  
  /// Atualiza a meta do usuário no Firestore
  Future<void> updateMeta(double novaMeta) async {
    final userId = _userId;
    if (userId == null) throw Exception("Usuário não logado");
    
    final userDoc = _firestore.collection('users').doc(userId);
    // Esta linha está correta
    await userDoc.set({'meta': novaMeta}, SetOptions(merge: true));
  }


  // --- Funções auxiliares de busca ---

  /// Busca a meta do documento do usuário (padrão 4000 se não existir)
  Future<double> _getMeta(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data()!.containsKey('meta')) {
        return (doc.data()!['meta'] ?? 4000.0).toDouble();
      }
      return 4000.0; 
    } catch (e) {
      return 4000.0; 
    }
  }
  
  /// Busca Receitas dentro do período
  Future<double> _getTotalReceitasDoMes(String userId, DateTime inicio, DateTime fim) async {
    final query = _firestore
        .collection('users')
        .doc(userId)
        .collection('receitas')
        .where('dataHora', isGreaterThanOrEqualTo: inicio)
        .where('dataHora', isLessThanOrEqualTo: fim);
    
    final aggregate = await query.aggregate(sum('valor')).get();
    
    return aggregate.getSum('valor') ?? 0.0;
  }

  /// Busca Despesas dentro do período
  Future<double> _getTotalDespesasDoMes(String userId, DateTime inicio, DateTime fim) async {
    final query = _firestore
        .collection('users')
        .doc(userId)
        .collection('despesas')
        .where('data', isGreaterThanOrEqualTo: inicio)
        .where('data', isLessThanOrEqualTo: fim);

    final aggregate = await query.aggregate(sum('valor')).get();
    
    return aggregate.getSum('valor') ?? 0.0;
  }
}