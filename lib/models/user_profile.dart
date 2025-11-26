typedef ValueGetter<T> = T Function();

class UserProfile {
  final String id;
  final String nome;
  final String? fotoUrl;
  final double meta;
  final String modeloVeiculo;
  final double kmPorLitro;
  final int intervaloTrocaOleo;
  final int kmAtual;
  
  // NOVOS CAMPOS PARA CÁLCULO E MANUTENÇÃO
  final double precoGasolinaAtual; 
  final int proximaTrocaOleoKm;    // KM alvo para a próxima troca de óleo
  final int proximaTrocaPneuKm;    // KM alvo para a próxima troca de pneu
  
  final bool isSetupComplete;

  UserProfile({
    required this.id,
    required this.nome,
    this.fotoUrl,
    required this.meta,
    required this.modeloVeiculo,
    required this.kmPorLitro,
    required this.intervaloTrocaOleo,
    required this.kmAtual,
    required this.precoGasolinaAtual,
    required this.proximaTrocaOleoKm,
    required this.proximaTrocaPneuKm,
    this.isSetupComplete = false,
  });

  UserProfile copyWith({
    String? id,
    String? nome,
    ValueGetter<String?>? fotoUrl,
    double? meta,
    String? modeloVeiculo,
    double? kmPorLitro,
    int? intervaloTrocaOleo,
    int? kmAtual,
    double? precoGasolinaAtual,
    int? proximaTrocaOleoKm,
    int? proximaTrocaPneuKm,
    bool? isSetupComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl != null ? fotoUrl() : this.fotoUrl,
      meta: meta ?? this.meta,
      modeloVeiculo: modeloVeiculo ?? this.modeloVeiculo,
      kmPorLitro: kmPorLitro ?? this.kmPorLitro,
      intervaloTrocaOleo: intervaloTrocaOleo ?? this.intervaloTrocaOleo,
      kmAtual: kmAtual ?? this.kmAtual,
      precoGasolinaAtual: precoGasolinaAtual ?? this.precoGasolinaAtual,
      proximaTrocaOleoKm: proximaTrocaOleoKm ?? this.proximaTrocaOleoKm,
      proximaTrocaPneuKm: proximaTrocaPneuKm ?? this.proximaTrocaPneuKm,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }

  // Mapeamento para persistência no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'fotoUrl': fotoUrl,
      'meta': meta,
      'modeloVeiculo': modeloVeiculo,
      'kmPorLitro': kmPorLitro,
      'intervaloTrocaOleo': intervaloTrocaOleo,
      'kmAtual': kmAtual,
      'precoGasolinaAtual': precoGasolinaAtual,
      'proximaTrocaOleoKm': proximaTrocaOleoKm,
      'proximaTrocaPneuKm': proximaTrocaPneuKm,
      'isSetupComplete': isSetupComplete,
    };
  }

  // Construção do objeto a partir do mapeamento do Firestore.
  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      nome: map['nome'] ?? '',
      fotoUrl: map['fotoUrl'],
      meta: (map['meta'] as num? ?? 4000.0).toDouble(),
      modeloVeiculo: map['modeloVeiculo'] ?? '',
      kmPorLitro: (map['kmPorLitro'] as num? ?? 0.0).toDouble(),
      intervaloTrocaOleo: map['intervaloTrocaOleo'] ?? 10000,
      kmAtual: map['kmAtual'] ?? 0,
      precoGasolinaAtual: (map['precoGasolinaAtual'] as num? ?? 0.0).toDouble(),
      proximaTrocaOleoKm: map['proximaTrocaOleoKm'] ?? 0,
      proximaTrocaPneuKm: map['proximaTrocaPneuKm'] ?? 0,
      isSetupComplete: map['isSetupComplete'] ?? false,
    );
  }

  // Criação de um objeto vazio com valores padrão para inicialização.
  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id,
      nome: '',
      meta: 4000,
      modeloVeiculo: '',
      kmPorLitro: 0,
      intervaloTrocaOleo: 10000,
      kmAtual: 0,
      precoGasolinaAtual: 0.0,
      proximaTrocaOleoKm: 0,
      proximaTrocaPneuKm: 0,
      isSetupComplete: false,
    );
  }
}