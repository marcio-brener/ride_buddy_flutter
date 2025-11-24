import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/jornada.dart';
import 'package:ride_buddy_flutter/services/jornada_service.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';

class JornadaListScreen extends StatelessWidget {
  const JornadaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JornadaService service = JornadaService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Jornadas Registradas"),
      body: StreamBuilder<List<Jornada>>(
        stream: service.getJornadas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar jornadas: ${snapshot.error}"));
          }
          final jornadas = snapshot.data ?? [];

          if (jornadas.isEmpty) {
            return const Center(child: Text("Nenhuma jornada registrada ainda."));
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jornadas.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final jornada = jornadas[index];
              return _buildJornadaItem(context, jornada, service);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildJornadaItem(BuildContext context, Jornada jornada, JornadaService service) {
    return ListTile(
      title: Text(
        "Viagem de ${DateFormat('dd/MM/yy', 'pt_BR').format(jornada.dataFim)}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("KM: ${jornada.kmPercorrido.toStringAsFixed(2)} km"),
          Text("Gasto Estimado: R\$ ${jornada.gastoGasolina.toStringAsFixed(2)}"),
          Text("Desgaste de Óleo: ${jornada.desgasteOleoKm.toStringAsFixed(0)} km"),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'excluir') {
            _confirmDelete(context, jornada, service);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'excluir', child: Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Jornada jornada, JornadaService service) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Jornada'),
          content: Text('Tem certeza que deseja excluir a jornada de ${DateFormat('dd/MM/yy', 'pt_BR').format(jornada.dataFim)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.deleteJornada(jornada.id);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Jornada excluída com sucesso.")),
                    );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}