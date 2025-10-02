import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';

class DespesasModal extends StatefulWidget {
  final BuildContext rootContext;
  final Function(Map<String, dynamic>) onSave;
  final Despesa? despesaToEdit;

  const DespesasModal({
    super.key,
    required this.rootContext,
    required this.onSave,
    this.despesaToEdit,
  });

  @override
  State<DespesasModal> createState() => _DespesasModalState();
}

class _DespesasModalState extends State<DespesasModal> {
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();

  final List<String> categorias = [ 'Combustível', 'Manutenção', 'Estacionamento', 'Alimentação', 'Outros' ];
  final List<String> formasPagamento = [ 'Dinheiro', 'Cartão de débito', 'Cartão de crédito', 'Pix' ];

  String? categoria;
  DateTime? data;
  String? formaPagamento;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.despesaToEdit != null;

    if (isEditing) {
      final despesa = widget.despesaToEdit!;
      categoria = despesa.categoria;
      _valorController.text = despesa.valor.toStringAsFixed(2);
      data = despesa.data;
      formaPagamento = despesa.formaPagamento;
      _observacoesController.text = despesa.observacoes;
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
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
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                isEditing ? 'Editar Despesa' : 'Adicionar Despesa',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Categoria
            DropdownButtonFormField<String>(
              value: categoria,
              decoration: InputDecoration(
                hintText: 'Categoria',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => categoria = val),
            ),
            const SizedBox(height: 12),
            
            // Valor
            TextField(
              controller: _valorController,
              decoration: InputDecoration(
                hintText: 'Valor',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            
            // Data
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: widget.rootContext,
                  initialDate: data ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() => data = selectedDate);
                }
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  data != null ? DateFormat('dd/MM/yyyy').format(data!) : 'Data da despesa',
                  style: TextStyle(color: data != null ? Colors.black : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Forma de pagamento
            DropdownButtonFormField<String>(
              value: formaPagamento,
              decoration: InputDecoration(
                hintText: 'Forma de pagamento',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: formasPagamento.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => formaPagamento = val),
            ),
            const SizedBox(height: 12),

            // Observações
            TextField(
              controller: _observacoesController,
              decoration: InputDecoration(
                hintText: 'Observações (opcional)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color.fromARGB(255, 248, 151, 33)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 248, 151, 33))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final valorDouble = double.tryParse(_valorController.text);
                      if (categoria != null && valorDouble != null && data != null && formaPagamento != null) {
                        widget.onSave({
                          'categoria': categoria,
                          'valor': valorDouble,
                          'data': data,
                          'formaPagamento': formaPagamento,
                          'observacoes': _observacoesController.text,
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                          const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color.fromARGB(255, 248, 151, 33)),
                        borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEditing ? 'Salvar' : 'Adicionar', style: const TextStyle(color: Color.fromARGB(255, 248, 151, 33))),
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