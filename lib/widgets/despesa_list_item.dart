import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DespesaListItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const DespesaListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      title: Text(
        item['categoria'],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Data: ${DateFormat('dd/MM/yyyy').format(item['data'])}\n'
        'Forma: ${item['formaPagamento']}${item['observacoes'].isNotEmpty ? "\nObs: ${item['observacoes']}" : ""}',
      ),
      trailing: Text(
        'R\$ ${item['valor'].toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF27214D),
        ),
      ),
    );
  }
}
