import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/despesa_list_item.dart';
import 'package:ride_buddy_flutter/widgets/despesas_modal.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  final List<Map<String, dynamic>> _despesas = [
    {
      'categoria': 'Combustível',
      'valor': 145.50,
      'data': DateTime(2025, 9, 10),
      'formaPagamento': 'Cartão de débito',
      'observacoes': 'Abastecimento no Posto Shell - Centro',
    },
    {
      'categoria': 'Manutenção',
      'valor': 270.00,
      'data': DateTime(2025, 9, 5),
      'formaPagamento': 'Pix',
      'observacoes': 'Troca de óleo na AutoCenter Bragança Paulista',
    },
    {
      'categoria': 'Estacionamento',
      'valor': 35.00,
      'data': DateTime(2025, 9, 12),
      'formaPagamento': 'Dinheiro',
      'observacoes': 'Estacionamento no Shopping Bragança Garden',
    },
    {
      'categoria': 'Alimentação',
      'valor': 60.90,
      'data': DateTime(2025, 9, 11),
      'formaPagamento': 'Cartão de crédito',
      'observacoes': 'Almoço com cliente no Restaurante Dona Chica',
    },
    {
      'categoria': 'Manutenção',
      'valor': 850.00,
      'data': DateTime(2025, 9, 3),
      'formaPagamento': 'Pix',
      'observacoes': 'Troca de pneus dianteiros na Pneus Bragança',
    },
    {
      'categoria': 'Combustível',
      'valor': 130.00,
      'data': DateTime(2025, 9, 15),
      'formaPagamento': 'Cartão de crédito',
      'observacoes': 'Abastecimento no Posto Ipiranga - Jardim do Lago',
    },
    {
      'categoria': 'Estacionamento',
      'valor': 45.00,
      'data': DateTime(2025, 9, 16),
      'formaPagamento': 'Dinheiro',
      'observacoes': 'Estacionamento próximo ao Terminal Rodoviário',
    },
    {
      'categoria': 'Alimentação',
      'valor': 23.50,
      'data': DateTime(2025, 9, 14),
      'formaPagamento': 'Dinheiro',
      'observacoes': 'Lanche rápido na Lanchonete McDonald\'s - Centro',
    },
    {
      'categoria': 'Manutenção',
      'valor': 50.00,
      'data': DateTime(2025, 9, 13),
      'formaPagamento': 'Pix',
      'observacoes': 'Lavagem completa no Lava Rápido Bragança Paulista',
    },
    {
      'categoria': 'Combustível',
      'valor': 140.00,
      'data': DateTime(2025, 9, 18),
      'formaPagamento': 'Cartão de débito',
      'observacoes': 'Abastecimento no Posto Petrobras - Centro',
    },
  ];

  double get total =>
      _despesas.fold(0, (sum, item) => sum + (item['valor'] as double));

  void _addDespesa(BuildContext rootContext) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return DespesasModal(
              rootContext: rootContext,
              onAdd: (despesa) {
                setState(() {
                  _despesas.add(despesa);
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
      appBar: const Header(text: "Despesas"),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _despesas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _despesas[index];

          return DespesaListItem(item: item);
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: _addDespesa,
      ),
    );
  }
}
