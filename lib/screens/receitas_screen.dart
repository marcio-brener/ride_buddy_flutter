import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/receita.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/widgets/receita_list_item.dart';
import 'package:ride_buddy_flutter/widgets/receita_modal.dart';
import 'package:ride_buddy_flutter/models/data_repository.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final List<Receita> _receitas = [ 
    Receita(
      app: "Uber",
      value: 45.50,
      distancia: 12.3,
      localSaida: "Terminal Rodoviário Bragança Paulista",
      localEntrada: "Jardim do Lago",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "iFood",
      value: 32.00,
      distancia: 7.8,
      localSaida: "Restaurante no Centro",
      localEntrada: "Planejada I",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "99Pop",
      value: 27.75,
      distancia: 6.4,
      localSaida: "Lago do Taboão",
      localEntrada: "Vila Aparecida",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Rappi",
      value: 22.50,
      distancia: 5.9,
      localSaida: "Supermercado União - Centro",
      localEntrada: "Jardim Águas Claras",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "99",
      value: 30.00,
      distancia: 9.5,
      localSaida: "Hospital Universitário São Francisco",
      localEntrada: "Parque dos Estados",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "VRDrive",
      value: 18.00,
      distancia: 4.2,
      localSaida: "Loja no Centro",
      localEntrada: "Bairro do Matadouro",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Uber",
      value: 40.00,
      distancia: 10.1,
      localSaida: "Bragança Garden Shopping",
      localEntrada: "Centro",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "iFood",
      value: 25.50,
      distancia: 6.7,
      localSaida: "Pizzaria Vila Rica - Centro",
      localEntrada: "Jardim Santa Helena",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Uber",
      value: 60.00,
      distancia: 15.4,
      localSaida: "Estádio Nabi Abi Chedid (Bragantino)",
      localEntrada: "Jardim São Lourenço",
      dataHora: DateTime.now(),
    ),
  ];

  double get total => _receitas.fold(0, (sum, receita) => sum + receita.value);

  void _openReceitaModal({Receita? receita, int? index}) {
    final List<String> apps = [ "Uber", "99", "iFood", "Frete", "Rappi", "InDrive", "VRDrive" ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ReceitaModal(
          apps: apps,
          rootContext: context,
          receitaToEdit: receita,
          onSave: (data) {
            final novaReceita = Receita(
              app: data['app'] as String,
              value: data['value'] as double,
              distancia: data['distancia'] as double,
              localSaida: data['localSaida'] as String,
              localEntrada: data['localEntrada'] as String,
              dataHora: data['dataHora'] as DateTime,
            );
            
            setState(() {
              if (index != null) {
                _receitas[index] = novaReceita;
              } else {
                _receitas.add(novaReceita);
                DataRepository().receitas.add(novaReceita);
              }
            });
          },
        );
      },
    );
  }

  void _deleteReceita(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          
          title: const Text(
            'Excluir Receita',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          
          content: const Text('Tem certeza que deseja excluir esta receita? Esta ação não pode ser desfeita.'),
          
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                setState(() {
                  _receitas.removeAt(index);
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Excluir'),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final Receita receita = _receitas[index];
          return ReceitaListItem(
            receita: receita,
            onEdit: () => _openReceitaModal(receita: receita, index: index),
            onDelete: () => _deleteReceita(index),
          );
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: (ctx) => _openReceitaModal(),
      ),
    );
  }
}