import 'package:cloud_firestore/cloud_firestore.dart';

class Receita {
  final String? id; // ID do firestore
  final String app;
  final double value;
  final double distancia;
  final String localSaida;
  final String localEntrada;
  final DateTime dataHora;

  Receita({
    this.id,
    required this.app,
    required this.value,
    required this.distancia,
    required this.localSaida,
    required this.localEntrada,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'app': app,
      'valor': value,
      'distancia': distancia,
      'localSaida': localSaida,
      'localEntrada': localEntrada,
      'dataHora': Timestamp.fromDate(dataHora),
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map, String documentId) {
    return Receita(
      id: documentId, // Armazena o ID
      app: map['app'] ?? '',
      value: (map['valor'] ?? 0).toDouble(),
      distancia: (map['distancia'] ?? 0).toDouble(),
      localSaida: map['localSaida'] ?? '',
      localEntrada: map['localEntrada'] ?? '',
      dataHora: (map['dataHora'] as Timestamp).toDate(), // Converte Timestamp para DateTime
    );
  }

}