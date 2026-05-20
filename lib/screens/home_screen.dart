import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';
import 'package:ride_buddy_flutter/models/receita.dart';
import 'package:ride_buddy_flutter/screens/despesas_screen.dart';
import 'package:ride_buddy_flutter/screens/receitas_screen.dart';
import 'package:ride_buddy_flutter/screens/relatorios_screen.dart';
import 'package:ride_buddy_flutter/screens/jornada_screen.dart';
import 'package:ride_buddy_flutter/screens/jornada_list_screen.dart';
import 'package:ride_buddy_flutter/services/despesa_service.dart';
import 'package:ride_buddy_flutter/services/receita_service.dart';
import 'package:ride_buddy_flutter/models/menu_item.dart';
import 'package:ride_buddy_flutter/widgets/custom_drawer.dart';
import 'package:ride_buddy_flutter/widgets/despesas_modal.dart';
import 'package:ride_buddy_flutter/widgets/receita_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryOrange = Color.fromARGB(255, 248, 151, 33);
  static const Color _profitGreen = Color(0xFF2E7D32);
  static const Color _profitGreenLight = Color(0xFFE8F5E9);
  static const Color _lossRed = Color(0xFFC62828);
  static const Color _lossRedLight = Color(0xFFFFEBEE);

  final ReceitaService _receitaService = ReceitaService();
  final DespesaService _despesaService = DespesaService();

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final List<String> _appsDisponiveis = const [
    "Uber",
    "99",
    "99Pop",
    "iFood",
    "Rappi",
    "VRDrive",
  ];

  // ATUALIZADA A LISTA DE ITENS
  final List<MenuItem> items = const [
    MenuItem(
      title: "Registrar Jornada",
      subtitle: "Inicie o rastreamento para calcular gasolina e desgaste.",
      image: "assets/capital.png",
    ),
    MenuItem(
      title: "Jornadas Anteriores",
      subtitle: "Visualize e gerencie seu histórico de viagens.",
      image: "assets/relatorio-de-negocios.png",
    ),
    MenuItem(
      title: "Receitas",
      subtitle:
          "Acompanhe suas receitas e mantenha o equilíbrio das suas finanças.",
      image: "assets/revenue-growth.png",
    ),
    MenuItem(
      title: "Despesas",
      subtitle:
          "Gerencie e registre seus gastos para manter o controle financeiro.",
      image: "assets/capital.png",
    ),
    MenuItem(
      title: "Relatórios",
      subtitle:
          "Visualize análises detalhadas para entender melhor sua situação financeira.",
      image: "assets/relatorio-de-negocios.png",
    ),
  ];

  void _navigateToPage(BuildContext context, int index) {
    Widget targetPage;

    if (index == 0) {
      targetPage = const JornadaScreen();
    } else if (index == 1) {
      targetPage = const JornadaListScreen();
    } else if (index == 2) {
      targetPage = ReceitasScreen();
    } else if (index == 3) {
      targetPage = const DespesasScreen();
    } else if (index == 4) {
      targetPage = const RelatoriosScreen();
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  double _totalDoDia(List<Receita> receitas) {
    return receitas
        .where((r) => _isToday(r.dataHora))
        .fold(0.0, (sum, r) => sum + r.value);
  }

  double _totalDespesasDoDia(List<Despesa> despesas) {
    return despesas
        .where((d) => _isToday(d.data))
        .fold(0.0, (sum, d) => sum + d.valor);
  }

  void _openReceitaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return ReceitaModal(
          rootContext: context,
          apps: _appsDisponiveis,
          onSave: (data) async {
            final novaReceita = Receita(
              app: data['app'],
              value: data['value'],
              distancia: data['distancia'],
              localSaida: data['localSaida'],
              localEntrada: data['localEntrada'],
              dataHora: data['dataHora'],
            );
            try {
              await _receitaService.addReceita(novaReceita);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Corrida registrada com sucesso!'),
                    backgroundColor: _profitGreen,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar receita: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  void _openDespesaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DespesasModal(
          rootContext: context,
          onSave: (data) async {
            final novaDespesa = Despesa(
              categoria: data['categoria'],
              valor: data['valor'],
              data: data['data'],
              formaPagamento: data['formaPagamento'],
              observacoes: data['observacoes'],
            );
            try {
              await _despesaService.addDespesa(novaDespesa);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gasto registrado com sucesso!'),
                    backgroundColor: _lossRed,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar despesa: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 120,
        title: const Text(
          "Ride Buddy",
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryOrange,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDailySummary(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Acesso rápido",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary() {
    return StreamBuilder<List<Receita>>(
      stream: _receitaService.getReceitas(),
      builder: (context, receitaSnapshot) {
        return StreamBuilder<List<Despesa>>(
          stream: _despesaService.getDespesas(),
          builder: (context, despesaSnapshot) {
            final receitas = receitaSnapshot.data ?? [];
            final despesas = despesaSnapshot.data ?? [];

            final totalReceitas = _totalDoDia(receitas);
            final totalDespesas = _totalDespesasDoDia(despesas);
            final lucro = totalReceitas - totalDespesas;
            final isPositive = lucro >= 0;
            final loading =
                receitaSnapshot.connectionState == ConnectionState.waiting ||
                    despesaSnapshot.connectionState == ConnectionState.waiting;

            return Column(
              children: [
                _buildProfitHero(lucro, isPositive, loading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniSummary(
                        label: "Receitas hoje",
                        value: totalReceitas,
                        icon: Icons.trending_up_rounded,
                        color: _profitGreen,
                        background: _profitGreenLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniSummary(
                        label: "Despesas hoje",
                        value: totalDespesas,
                        icon: Icons.trending_down_rounded,
                        color: _lossRed,
                        background: _lossRedLight,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfitHero(double lucro, bool isPositive, bool loading) {
    final color = isPositive ? _profitGreen : _lossRed;
    final gradient = isPositive
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          );

    final today =
        DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lucro do dia",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? "Positivo" : "Negativo",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          loading
              ? const SizedBox(
                  height: 38,
                  width: 38,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  _currency.format(lucro),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            today,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currency.format(value),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            label: "Registrar Corrida",
            icon: Icons.add_road_rounded,
            color: _profitGreen,
            onTap: _openReceitaModal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            label: "Registrar Gasto",
            icon: Icons.payments_rounded,
            color: _lossRed,
            onTap: _openDespesaModal,
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToPage(context, index),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Image.asset(item.image, width: 44, height: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
