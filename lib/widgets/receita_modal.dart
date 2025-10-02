import 'package:flutter/material.dart';

class ReceitaDialog extends StatefulWidget {
  final List<String> apps;
  final Function(Map<String, dynamic>) onAdd;

  const ReceitaDialog({super.key, required this.apps, required this.onAdd});

  @override
  State<ReceitaDialog> createState() => _ReceitaDialogState();
}

class _ReceitaDialogState extends State<ReceitaDialog> {
  String? appSelecionado;
  String value = "";
  String distancia = "";
  String localSaida = "";
  String localEntrada = "";
  DateTime? dataHora;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Receita'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Aplicativo"),
              value: appSelecionado,
              items: widget.apps
                  .map((app) => DropdownMenuItem(value: app, child: Text(app)))
                  .toList(),
              onChanged: (val) => setState(() => appSelecionado = val),
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Valor'),
              keyboardType: TextInputType.number,
              onChanged: (val) => value = val,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Distância (km)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => distancia = val,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Local de saída'),
              onChanged: (val) => localSaida = val,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Local de chegada'),
              onChanged: (val) => localEntrada = val,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      dataHora = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(
                dataHora == null
                    ? 'Selecionar Data e Hora'
                    : '${dataHora!.day}/${dataHora!.month}/${dataHora!.year} '
                          '${dataHora!.hour.toString().padLeft(2, '0')}:'
                          '${dataHora!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (appSelecionado != null &&
                value.isNotEmpty &&
                distancia.isNotEmpty &&
                localSaida.isNotEmpty &&
                localEntrada.isNotEmpty) {
              widget.onAdd({
                'app': appSelecionado,
                'value': double.tryParse(value) ?? 0,
                'distancia': double.tryParse(distancia) ?? 0,
                'localSaida': localSaida,
                'localEntrada': localEntrada,
                'dataHora': dataHora ?? DateTime.now(),
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
