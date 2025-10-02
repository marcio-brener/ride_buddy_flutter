import 'receita.dart';
import 'despesa.dart';

class DataRepository {
  static final DataRepository _instance = DataRepository._internal();

  factory DataRepository() => _instance;

  DataRepository._internal();

  final List<Receita> receitas = [];
  final List<Despesa> despesas = [];

  double get totalReceitas =>
      receitas.fold(0, (sum, item) => sum + item.value);

  double get totalDespesas =>
      despesas.fold(0, (sum, item) => sum + item.valor);

  double get meta => 4000.0;

  double get progresso => (totalReceitas / meta).clamp(0, 1);
}
