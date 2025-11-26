import 'package:cloud_firestore/cloud_firestore.dart';

class Jornada {
  final String id;
  final DateTime dataFim;
  final double kmPercorrido;
  final int duracaoSegundos; 

  // Variáveis calculadas
  final double gastoGasolina;
  final double desgasteOleoKm;
  final double desgastePneuKm;

  Jornada({
    required this.id,
    required this.dataFim,
    required this.kmPercorrido,
    required this.duracaoSegundos, 
    required this.gastoGasolina,
    required this.desgasteOleoKm,
    required this.desgastePneuKm,
  });

  /// Mapeamento para persistência no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'dataFim': Timestamp.fromDate(dataFim),
      'kmPercorrido': kmPercorrido,
      'duracaoSegundos': duracaoSegundos,
      'gastoGasolina': gastoGasolina,
      'desgasteOleoKm': desgasteOleoKm,
      'desgastePneuKm': desgastePneuKm,
    };
  }

  /// Construção do objeto a partir do mapeamento do Firestore.
  factory Jornada.fromMap(Map<String, dynamic> map, String documentId) {
    final getDouble = (key) => (map[key] ?? 0.0).toDouble();
    
    return Jornada(
      id: documentId,
      dataFim: (map['dataFim'] as Timestamp).toDate(),
      kmPercorrido: getDouble('kmPercorrido'),
      duracaoSegundos: map['duracaoSegundos'] ?? 0, 
      gastoGasolina: getDouble('gastoGasolina'),
      desgasteOleoKm: getDouble('desgasteOleoKm'),
      desgastePneuKm: getDouble('desgastePneuKm'),
    );
  }

  Jornada copyWith({
    String? id,
    DateTime? dataFim,
    double? kmPercorrido,
    int? duracaoSegundos, 
    double? gastoGasolina,
    double? desgasteOleoKm,
    double? desgastePneuKm,
  }) {
    return Jornada(
      id: id ?? this.id,
      dataFim: dataFim ?? this.dataFim,
      kmPercorrido: kmPercorrido ?? this.kmPercorrido,
      duracaoSegundos: duracaoSegundos ?? this.duracaoSegundos, 
      gastoGasolina: gastoGasolina ?? this.gastoGasolina,
      desgasteOleoKm: desgasteOleoKm ?? this.desgasteOleoKm,
      desgastePneuKm: desgastePneuKm ?? this.desgastePneuKm,
    );
  }
}