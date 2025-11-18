import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/relatorio.dart';
import 'package:ride_buddy_flutter/services/relatorio_service.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen>
    with WidgetsBindingObserver {
  final RelatorioService _service = RelatorioService();

  DateTime _selectedMonth = DateTime.now();
  Future<Relatorio>? _relatorioFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  void _fetchData() {
    setState(() {
      _relatorioFuture = _service.getRelatorioMensal(_selectedMonth);
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + increment,
        1,
      );
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final String mesFormatado =
        DateFormat('MMMM / y', 'pt_BR').format(_selectedMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Relatórios"),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  "${mesFormatado[0].toUpperCase()}${mesFormatado.substring(1)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Relatorio>(
              future: _relatorioFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text("Erro ao carregar relatório: ${snapshot.error}"),
                  );
                }

                final relatorio = snapshot.data ?? Relatorio.vazio();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  "Meta Mensal",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "R\$ ${relatorio.meta.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: relatorio.progresso,
                                backgroundColor: Colors.grey[300],
                                color: Colors.green,
                                minHeight: 12,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${(relatorio.progresso * 100).toStringAsFixed(1)}% atingido",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        title: "Ganhos (Receitas)",
                        value: relatorio.totalReceitas,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: "Gastos (Despesas)",
                        value: relatorio.totalDespesas,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                "Resumo Geral",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              _buildResumoRow(
                                title: "Lucro Líquido:",
                                value: relatorio.lucroLiquido,
                                color: relatorio.lucroLiquido >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(height: 8),
                              _buildResumoRow(
                                title: "Meta Restante:",
                                value: relatorio.metaRestante,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required double value, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "R\$ ${value.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoRow(
      {required String title, required double value, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          "R\$ ${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}