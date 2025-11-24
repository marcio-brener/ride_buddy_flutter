import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_buddy_flutter/models/relatorio.dart';

class RelatorioService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Busca todos os dados e calcula o relatório para um mês específico.
  Future<Relatorio> getRelatorioMensal(DateTime mes) async {
    final userId = _userId;
    if (userId == null) throw Exception("Usuário não logado");

    final inicioMes = DateTime(mes.year, mes.month, 1);
    final fimMes = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);

    final metaFuture = _getMeta(userId);
    final totalReceitasFuture = _getTotalReceitasDoMes(userId, inicioMes, fimMes);
    final totalDespesasManualFuture = _getTotalDespesasDoMes(userId, inicioMes, fimMes);
    final gastoGasolinaFuture = _getTotalGastoGasolinaDoMes(userId, inicioMes, fimMes);

    final results = await Future.wait([
      metaFuture,
      totalReceitasFuture,
      totalDespesasManualFuture,
      gastoGasolinaFuture,
    ]);

    final double meta = results[0];
    final double totalReceitas = results[1];
    final double totalDespesasManual = results[2];
    final double gastoGasolinaAutomatico = results[3];

    // Total de Despesas inclui Despesas Manuais + Gasolina Automática
    final double totalDespesas = totalDespesasManual + gastoGasolinaAutomatico;

    return Relatorio(
      totalReceitas: totalReceitas,
      totalDespesas: totalDespesas,
      meta: meta,
    );
  }

  /// (Função updateMeta continua aqui...)
  Future<void> updateMeta(double novaMeta) async {
    final userId = _userId;
    if (userId == null) throw Exception("Usuário não logado");
    
    final userDoc = _firestore.collection('users').doc(userId);
    await userDoc.set({'meta': novaMeta}, SetOptions(merge: true));
  }


  /// Recupera a meta do documento do usuário.
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

  /// Soma o valor total das Receitas do mês.
  Future<double> _getTotalReceitasDoMes(String userId, DateTime inicio, DateTime fim) async {
    final query = _firestore
        .collection('users').doc(userId)
        .collection('receitas')
        .where('dataHora', isGreaterThanOrEqualTo: inicio)
        .where('dataHora', isLessThanOrEqualTo: fim);
    
    final aggregate = await query.aggregate(sum('valor')).get();
    return aggregate.getSum('valor') ?? 0.0;
  }

  /// Soma o valor total das Despesas Manuais do mês.
  Future<double> _getTotalDespesasDoMes(String userId, DateTime inicio, DateTime fim) async {
    final query = _firestore
        .collection('users').doc(userId)
        .collection('despesas')
        .where('data', isGreaterThanOrEqualTo: inicio)
        .where('data', isLessThanOrEqualTo: fim);

    final aggregate = await query.aggregate(sum('valor')).get();
    return aggregate.getSum('valor') ?? 0.0;
  }
  
  /// Soma o Gasto total de Gasolina (despesa automática) do mês.
  Future<double> _getTotalGastoGasolinaDoMes(String userId, DateTime inicio, DateTime fim) async {
    final query = _firestore
        .collection('users').doc(userId)
        .collection('jornadas')
        .where('dataFim', isGreaterThanOrEqualTo: inicio)
        .where('dataFim', isLessThanOrEqualTo: fim);

    // Soma o campo 'gastoGasolina' da coleção 'jornadas'
    final aggregate = await query.aggregate(sum('gastoGasolina')).get();
    
    return aggregate.getSum('gastoGasolina') ?? 0.0;
  }
}