import 'package:cloud_firestore/cloud_firestore.dart';

class Despesa {
  final String? id; // ID do firestore
  final String categoria;
  final double valor;
  final DateTime data;
  final String formaPagamento;
  final String observacoes;

  Despesa({
    this.id,
    required this.categoria,
    required this.valor,
    required this.data,
    required this.formaPagamento,
    required this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'valor': valor,
      'data': Timestamp.fromDate(data),
      'formaPagamento': formaPagamento,
      'observacoes': observacoes,
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map, String documentId) {
    return Despesa(
      id: documentId, // Armazena o ID
      categoria: map['categoria'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      data: (map['data'] as Timestamp).toDate(), // Converte Timestamp para DateTime
      formaPagamento: map['formaPagamento'] ?? '',
      observacoes: map['observacoes'] ?? '',
    );
  }
}

