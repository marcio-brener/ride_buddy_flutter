import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceitaModal extends StatefulWidget {
  final List<String> apps;
  final Function(Map<String, dynamic>) onAdd;
  final BuildContext rootContext;

  const ReceitaModal({
    super.key,
    required this.apps,
    required this.onAdd,
    required this.rootContext,
  });

  @override
  State<ReceitaModal> createState() => _ReceitaModalState();
}

class _ReceitaModalState extends State<ReceitaModal> {
  String? appSelecionado;
  String value = "";
  String distancia = "";
  String localSaida = "";
  String localEntrada = "";
  DateTime? dataHora;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(widget.rootContext).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// Botão de fechar
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Aplicativo
            DropdownButtonFormField<String>(
              value: appSelecionado,
              decoration: InputDecoration(
                hintText: 'Aplicativo',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.apps
                  .map((app) => DropdownMenuItem(value: app, child: Text(app)))
                  .toList(),
              onChanged: (val) => setState(() => appSelecionado = val),
            ),
            const SizedBox(height: 10),

            /// Valor
            TextField(
              decoration: InputDecoration(
                hintText: 'Valor',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => value = val,
            ),
            const SizedBox(height: 12),

            /// Distância
            TextField(
              decoration: InputDecoration(
                hintText: 'Distância (km)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => distancia = val,
            ),
            const SizedBox(height: 12),

            /// Local de saída
            TextField(
              decoration: InputDecoration(
                hintText: 'Local de saída',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => localSaida = val,
            ),
            const SizedBox(height: 12),

            /// Local de chegada
            TextField(
              decoration: InputDecoration(
                hintText: 'Local de chegada',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => localEntrada = val,
            ),
            const SizedBox(height: 12),

            /// Data e hora
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: widget.rootContext,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: widget.rootContext,
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
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dataHora != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(dataHora!)
                      : 'Selecionar Data e Hora',
                  style: TextStyle(
                    color: dataHora != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromARGB(255, 248, 151, 33),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color.fromARGB(255, 248, 151, 33),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (appSelecionado != null &&
                          value.isNotEmpty &&
                          distancia.isNotEmpty &&
                          localSaida.isNotEmpty &&
                          localEntrada.isNotEmpty &&
                          dataHora != null) {
                        widget.onAdd({
                          'app': appSelecionado,
                          'value': double.tryParse(value) ?? 0,
                          'distancia': double.tryParse(distancia) ?? 0,
                          'localSaida': localSaida,
                          'localEntrada': localEntrada,
                          'dataHora': dataHora!,
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, preencha todos os campos obrigatórios.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 248, 151, 33),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(
                        color: Color.fromARGB(255, 248, 151, 33),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
