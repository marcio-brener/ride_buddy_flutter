import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/screens/despesas_screen.dart';
import 'package:ride_buddy_flutter/screens/receitas_screen.dart';
import 'package:ride_buddy_flutter/screens/relatorios_screen.dart';
import 'package:ride_buddy_flutter/screens/jornada_screen.dart'; 
import 'package:ride_buddy_flutter/screens/jornada_list_screen.dart'; 
import 'package:ride_buddy_flutter/models/menu_item.dart';
import 'package:ride_buddy_flutter/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ATUALIZADA A LISTA DE ITENS
  final List<MenuItem> items = const [
    MenuItem(
      title: "Registrar Jornada",
      subtitle: "Inicie o rastreamento para calcular gasolina e desgaste.",
      image: "assets/capital.png", // Use um ícone relevante
    ),
    MenuItem(
      title: "Jornadas Anteriores",
      subtitle: "Visualize e gerencie seu histórico de viagens.",
      image: "assets/relatorio-de-negocios.png", // Use um ícone relevante
    ),
    MenuItem(
      title: "Receitas",
      subtitle: "Acompanhe suas receitas e mantenha o equilíbrio das suas finanças.",
      image: "assets/revenue-growth.png",
    ),
    MenuItem(
      title: "Despesas",
      subtitle: "Gerencie e registre seus gastos para manter o controle financeiro.",
      image: "assets/capital.png",
    ),
    MenuItem(
      title: "Relatórios",
      subtitle: "Visualize análises detalhadas para entender melhor sua situação financeira.",
      image: "assets/relatorio-de-negocios.png",
    ),
  ];

  void _navigateToPage(BuildContext context, int index) {
    Widget targetPage;
    
    // Mapeamento de índices atualizado
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: const Color.fromARGB(255, 248, 151, 33),
      ),
      drawer: const CustomDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
        const Divider(thickness: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: Image.asset(item.image, width: 50, height: 50),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.subtitle),
            onTap: () => _navigateToPage(context, index),
          );
        },
      ),
    );
  }
}