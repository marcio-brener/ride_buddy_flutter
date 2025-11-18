class UserProfile {
  final String id;
  final String nome;
  final String? fotoUrl;
  final double meta;
  final String modeloVeiculo;
  final double kmPorLitro;
  final int intervaloTrocaOleo;
  final int kmAtual;
  
  // NOVO CAMPO:
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
    this.isSetupComplete = false, // Padrão é falso
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
      'isSetupComplete': isSetupComplete, // Salva no banco
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
      isSetupComplete: map['isSetupComplete'] ?? false, // Lê do banco
    );
  }
  
  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id, nome: '', meta: 4000, modeloVeiculo: '', 
      kmPorLitro: 0, intervaloTrocaOleo: 10000, kmAtual: 0,
      isSetupComplete: false,
    );
  }
}