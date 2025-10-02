class Receita {
  final String app;
  final double value;
  final double distancia;
  final String localSaida;
  final String localEntrada;
  final DateTime dataHora;

  Receita({
    required this.app,
    required this.value,
    required this.distancia,
    required this.localSaida,
    required this.localEntrada,
    required this.dataHora,
  });
}