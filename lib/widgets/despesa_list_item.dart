import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';

class DespesaListItem extends StatelessWidget {
  final Despesa despesa; 
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DespesaListItem({
    super.key,
    required this.despesa,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        despesa.categoria,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Data: ${DateFormat('dd/MM/yyyy').format(despesa.data)}\n'
        'Forma: ${despesa.formaPagamento}${despesa.observacoes.isNotEmpty ? "\nObs: ${despesa.observacoes}" : ""}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'R\$ ${despesa.valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF27214D),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'Editar') {
                onEdit();
              } else if (value == 'Excluir') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Editar', child: Text('Editar')),
              PopupMenuItem(value: 'Excluir', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }
}