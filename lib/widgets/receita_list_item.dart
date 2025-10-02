import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReceitaListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final DateTime dataHora;
  final Map<String, String> appLogos = {
    "Uber": "assets/uber-logo.png",
    "99": "assets/99-logo.png",
    "99Pop": "assets/99-logo.png",
    "iFood": "assets/ifood-logo.png",
    "Rappi": "assets/rappi-logo.png",
    "VRDrive": "assets/vrdrive-logo.png",
  };

  ReceitaListItem({super.key, required this.item, required this.dataHora});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: appLogos[item['app']] != null
          ? Image.asset(appLogos[item['app']]!, width: 40, height: 40)
          : null,
      title: Text(
        item['app'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${item['localSaida']} → ${item['localEntrada']}"),
          const SizedBox(height: 4),
          Text("Distância: ${item['distancia']} km"),
          const SizedBox(height: 2),
          Text(
            "Data/Hora: ${dataHora.day}/${dataHora.month}/${dataHora.year} ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
      trailing: Text(
        'R\$ ${item['value'].toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF27214D),
        ),
      ),
    );
  }
}
