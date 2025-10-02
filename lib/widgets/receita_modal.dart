import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/receita.dart';

class ReceitaModal extends StatefulWidget {
  final List<String> apps;
  final Function(Map<String, dynamic>) onSave;
  final BuildContext rootContext;
  final Receita? receitaToEdit;

  const ReceitaModal({
    super.key,
    required this.apps,
    required this.onSave,
    required this.rootContext,
    this.receitaToEdit,
  });

  @override
  State<ReceitaModal> createState() => _ReceitaModalState();
}

class _ReceitaModalState extends State<ReceitaModal> {
  final _valueController = TextEditingController();
  final _distanciaController = TextEditingController();
  final _localSaidaController = TextEditingController();
  final _localEntradaController = TextEditingController();

  String? appSelecionado;
  DateTime? dataHora;

  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.receitaToEdit != null;

    if (isEditing) {
      appSelecionado = widget.receitaToEdit!.app;
      _valueController.text = widget.receitaToEdit!.value.toStringAsFixed(2);
      _distanciaController.text = widget.receitaToEdit!.distancia.toString();
      _localSaidaController.text = widget.receitaToEdit!.localSaida;
      _localEntradaController.text = widget.receitaToEdit!.localEntrada;
      dataHora = widget.receitaToEdit!.dataHora;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _distanciaController.dispose();
    _localSaidaController.dispose();
    _localEntradaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(widget.rootContext).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
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
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                isEditing ? 'Editar Receita' : 'Adicionar Receita',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

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

            TextField(
              controller: _valueController,
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
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distanciaController,
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
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localSaidaController,
              decoration: InputDecoration(
                hintText: 'Local de saída',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localEntradaController,
              decoration: InputDecoration(
                hintText: 'Local de chegada',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: widget.rootContext,
                    initialDate: dataHora ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: widget.rootContext,
                      initialTime: TimeOfDay.fromDateTime(dataHora ?? DateTime.now()),
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
                          _valueController.text.isNotEmpty &&
                          _distanciaController.text.isNotEmpty &&
                          _localSaidaController.text.isNotEmpty &&
                          _localEntradaController.text.isNotEmpty &&
                          dataHora != null) {
                        widget.onSave({ 
                          'app': appSelecionado,
                          'value': double.tryParse(_valueController.text) ?? 0,
                          'distancia': double.tryParse(_distanciaController.text) ?? 0,
                          'localSaida': _localSaidaController.text,
                          'localEntrada': _localEntradaController.text,
                          'dataHora': dataHora!,
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, preencha todos os campos.',
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
                    child: Text( 
                      isEditing ? 'Salvar' : 'Adicionar',
                      style: const TextStyle(
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