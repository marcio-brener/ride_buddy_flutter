class Despesa {
  final String categoria;
  final double valor;
  final DateTime data;
  final String formaPagamento;
  final String observacoes;

  Despesa({
    required this.categoria,
    required this.valor,
    required this.data,
    required this.formaPagamento,
    required this.observacoes,
  });
}