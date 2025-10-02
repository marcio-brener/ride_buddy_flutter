import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DespesasModal extends StatefulWidget {
  final BuildContext rootContext;
  final Function(Map<String, dynamic>) onAdd;

  const DespesasModal({
    super.key,
    required this.rootContext,
    required this.onAdd,
  });

  @override
  State<DespesasModal> createState() => _DespesasModal();
}

class _DespesasModal extends State<DespesasModal> {
  final List<String> categorias = [
    'Combustível',
    'Manutenção',
    'Estacionamento',
    'Alimentação',
    'Outros',
  ];

  final List<String> formasPagamento = [
    'Dinheiro',
    'Cartão de débito',
    'Cartão de crédito',
    'Pix',
  ];

  String? categoria;
  String valor = "";
  DateTime? data;
  String? formaPagamento;
  String observacoes = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(widget.rootContext).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

            /// Categoria
            DropdownButtonFormField<String>(
              value: categoria,
              decoration: InputDecoration(
                hintText: 'Categoria',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => categoria = val),
            ),
            const SizedBox(height: 12),

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
              onChanged: (val) => setState(() => valor = val),
            ),
            const SizedBox(height: 12),

            /// Data
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: widget.rootContext,
                  initialDate: DateTime.now(),
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data != null
                      ? DateFormat('dd/MM/yyyy').format(data!)
                      : 'Data da despesa',
                  style: TextStyle(
                    color: data != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Forma de pagamento
            DropdownButtonFormField<String>(
              value: formaPagamento,
              decoration: InputDecoration(
                hintText: 'Forma de pagamento',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: formasPagamento
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => formaPagamento = val),
            ),
            const SizedBox(height: 12),

            /// Observações
            TextField(
              decoration: InputDecoration(
                hintText: 'Observações (opcional)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
              onChanged: (val) => setState(() => observacoes = val),
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
                      double? valorDouble = double.tryParse(valor);
                      if (categoria == null ||
                          valor.isEmpty ||
                          valorDouble == null ||
                          valorDouble <= 0 ||
                          data == null ||
                          formaPagamento == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, preencha todos os campos obrigatórios.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      widget.onAdd({
                        'categoria': categoria,
                        'valor': valorDouble,
                        'data': data,
                        'formaPagamento': formaPagamento,
                        'observacoes': observacoes,
                      });
                      Navigator.pop(context);
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
