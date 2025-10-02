// lib/screens/despesas_screen.dart

import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/despesa_list_item.dart';
import 'package:ride_buddy_flutter/widgets/despesas_modal.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';
import 'package:ride_buddy_flutter/models/data_repository.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  final List<Despesa> _despesas = [
    Despesa(
      categoria: 'Combustível',
      valor: 145.50,
      data: DateTime(2025, 9, 10),
      formaPagamento: 'Cartão de débito',
      observacoes: 'Abastecimento no Posto Shell - Centro',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 270.00,
      data: DateTime(2025, 9, 5),
      formaPagamento: 'Pix',
      observacoes: 'Troca de óleo na AutoCenter Bragança Paulista',
    ),
    Despesa(
      categoria: 'Estacionamento',
      valor: 35.00,
      data: DateTime(2025, 9, 12),
      formaPagamento: 'Dinheiro',
      observacoes: 'Estacionamento no Shopping Bragança Garden',
    ),
    Despesa(
      categoria: 'Alimentação',
      valor: 60.90,
      data: DateTime(2025, 9, 11),
      formaPagamento: 'Cartão de crédito',
      observacoes: 'Almoço com cliente no Restaurante Dona Chica',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 850.00,
      data: DateTime(2025, 9, 3),
      formaPagamento: 'Pix',
      observacoes: 'Troca de pneus dianteiros na Pneus Bragança',
    ),
    Despesa(
      categoria: 'Combustível',
      valor: 130.00,
      data: DateTime(2025, 9, 15),
      formaPagamento: 'Cartão de crédito',
      observacoes: 'Abastecimento no Posto Ipiranga - Jardim do Lago',
    ),
    Despesa(
      categoria: 'Estacionamento',
      valor: 45.00,
      data: DateTime(2025, 9, 16),
      formaPagamento: 'Dinheiro',
      observacoes: 'Estacionamento próximo ao Terminal Rodoviário',
    ),
    Despesa(
      categoria: 'Alimentação',
      valor: 23.50,
      data: DateTime(2025, 9, 14),
      formaPagamento: 'Dinheiro',
      observacoes: 'Lanche rápido na Lanchonete McDonald\'s - Centro',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 50.00,
      data: DateTime(2025, 9, 13),
      formaPagamento: 'Pix',
      observacoes: 'Lavagem completa no Lava Rápido Bragança Paulista',
    ),
    Despesa(
      categoria: 'Combustível',
      valor: 140.00,
      data: DateTime(2025, 9, 18),
      formaPagamento: 'Cartão de débito',
      observacoes: 'Abastecimento no Posto Petrobras - Centro',
    ),
  ];

  double get total => _despesas.fold(0, (sum, item) => sum + item.valor);

  void _openDespesaModal({Despesa? despesa, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DespesasModal(
          rootContext: context,
          despesaToEdit: despesa,
          onSave: (data) {
            final novaDespesa = Despesa(
              categoria: data['categoria'],
              valor: data['valor'],
              data: data['data'],
              formaPagamento: data['formaPagamento'],
              observacoes: data['observacoes'],
            );

            setState(() {
              if (index != null) {
                _despesas[index] = novaDespesa;
              } else {
                _despesas.add(novaDespesa);
                DataRepository().despesas.add(novaDespesa);
              }
            });
          },
        );
      },
    );
  }

  void _deleteDespesa(int index) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        
        title: const Text(
          'Excluir Despesa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        
        content: const Text('Tem certeza que deseja excluir esta despesa? Esta ação não pode ser desfeita.'),
        
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
                _despesas.removeAt(index);
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
      appBar: const Header(text: "Despesas"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _despesas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final despesa = _despesas[index];
          return DespesaListItem(
            despesa: despesa,
            onEdit: () => _openDespesaModal(despesa: despesa, index: index),
            onDelete: () => _deleteDespesa(index),
          );
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: (ctx) => _openDespesaModal(),
      ),
    );
  }
}