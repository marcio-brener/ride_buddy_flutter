class UserProfile {
  final String id;
  final String nome;
  final String? fotoUrl; // URL da foto (pode ser null)
  final double meta;
  
  // Dados do Veículo
  final String modeloVeiculo;
  final double kmPorLitro; // Consumo médio
  final int intervaloTrocaOleo; // Ex: 10000 km
  final int kmAtual; // Para calcular a próxima troca

  UserProfile({
    required this.id,
    required this.nome,
    this.fotoUrl,
    required this.meta,
    required this.modeloVeiculo,
    required this.kmPorLitro,
    required this.intervaloTrocaOleo,
    required this.kmAtual,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'fotoUrl': fotoUrl,
      'meta': meta,
      'modeloVeiculo': modeloVeiculo,
      'kmPorLitro': kmPorLitro,
      'intervaloTrocaOleo': intervaloTrocaOleo,
      'kmAtual': kmAtual,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      nome: map['nome'] ?? '',
      fotoUrl: map['fotoUrl'],
      meta: (map['meta'] ?? 0).toDouble(),
      modeloVeiculo: map['modeloVeiculo'] ?? '',
      kmPorLitro: (map['kmPorLitro'] ?? 0).toDouble(),
      intervaloTrocaOleo: map['intervaloTrocaOleo'] ?? 10000,
      kmAtual: map['kmAtual'] ?? 0,
    );
  }
  
  // Fábrica para usuário vazio/novo
  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id, nome: '', meta: 4000, modeloVeiculo: '', 
      kmPorLitro: 0, intervaloTrocaOleo: 1000, kmAtual: 0
    );
  }
}