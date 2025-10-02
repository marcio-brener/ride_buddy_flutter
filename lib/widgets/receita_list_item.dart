import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/receita.dart';

class ReceitaListItem extends StatelessWidget {
  final Receita receita;
  
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final Map<String, String> appLogos = {
    "Uber": "assets/uber-logo.png",
    "99": "assets/99-logo.png",
    "99Pop": "assets/99-logo.png",
    "iFood": "assets/ifood-logo.png",
    "Rappi": "assets/rappi-logo.png",
    "VRDrive": "assets/vrdrive-logo.png",
  };

  ReceitaListItem({
    super.key,
    required this.receita,
    required this.onEdit, 
    required this.onDelete, 
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: appLogos[receita.app] != null
          ? Image.asset(appLogos[receita.app]!, width: 40, height: 40)
          : null,
      title: Text(
        receita.app,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${receita.localSaida} → ${receita.localEntrada}"),
          const SizedBox(height: 4),
          Text("Distância: ${receita.distancia} km"),
          const SizedBox(height: 2),
          Text(
            "Data/Hora: ${receita.dataHora.day}/${receita.dataHora.month}/${receita.dataHora.year} ${receita.dataHora.hour.toString().padLeft(2, '0')}:${receita.dataHora.minute.toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'R\$ ${receita.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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