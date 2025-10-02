import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/widgets/receita_list_item.dart';
import 'package:ride_buddy_flutter/widgets/receita_modal.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final List<Map<String, dynamic>> _receitas = [
    {
      "app": "Uber",
      "value": 45.50,
      "distancia": 12.3,
      "localSaida": "Terminal Rodoviário Bragança Paulista",
      "localEntrada": "Jardim do Lago",
      "dataHora": DateTime.now(),
    },
    {
      "app": "iFood",
      "value": 32.00,
      "distancia": 7.8,
      "localSaida": "Restaurante no Centro",
      "localEntrada": "Planejada I",
      "dataHora": DateTime.now(),
    },
    {
      "app": "99Pop",
      "value": 27.75,
      "distancia": 6.4,
      "localSaida": "Lago do Taboão",
      "localEntrada": "Vila Aparecida",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Rappi",
      "value": 22.50,
      "distancia": 5.9,
      "localSaida": "Supermercado União - Centro",
      "localEntrada": "Jardim Águas Claras",
      "dataHora": DateTime.now(),
    },
    {
      "app": "99",
      "value": 30.00,
      "distancia": 9.5,
      "localSaida": "Hospital Universitário São Francisco",
      "localEntrada": "Parque dos Estados",
      "dataHora": DateTime.now(),
    },
    {
      "app": "VRDrive",
      "value": 18.00,
      "distancia": 4.2,
      "localSaida": "Loja no Centro",
      "localEntrada": "Bairro do Matadouro",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Uber",
      "value": 40.00,
      "distancia": 10.1,
      "localSaida": "Bragança Garden Shopping",
      "localEntrada": "Centro",
      "dataHora": DateTime.now(),
    },
    {
      "app": "iFood",
      "value": 25.50,
      "distancia": 6.7,
      "localSaida": "Pizzaria Vila Rica - Centro",
      "localEntrada": "Jardim Santa Helena",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Uber",
      "value": 60.00,
      "distancia": 15.4,
      "localSaida": "Estádio Nabi Abi Chedid (Bragantino)",
      "localEntrada": "Jardim São Lourenço",
      "dataHora": DateTime.now(),
    },
  ];

  double get total =>
      _receitas.fold(0, (sum, item) => sum + (item['value'] as double));

  void _addReceita(BuildContext rootContext) {
    String? appSelecionado;
    String value = '';
    String distancia = '';
    String localSaida = '';
    String localEntrada = '';
    DateTime? dataHora;

    final List<String> _apps = [
      "Uber",
      "99",
      "iFood",
      "Frete",
      "Rappi",
      "InDrive",
      "VRDrive",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return ReceitaDialog(
              apps: _apps,
              onAdd: (receita) {
                setState(() {
                  _receitas.add(receita);
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Receitas"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _receitas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _receitas[index];

          return ReceitaListItem(
            item: item,
            dataHora: item['dataHora'] ?? DateTime.now(),
          );
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: _addReceita,
      ),
    );
  }
}
