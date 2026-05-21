import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';
import 'package:ride_buddy_flutter/models/template.dart';
import 'package:ride_buddy_flutter/services/template_service.dart';
import 'package:ride_buddy_flutter/widgets/save_template_dialog.dart';
import 'package:ride_buddy_flutter/widgets/template_chip_row.dart';

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
  final _templateService = TemplateService();

  final List<String> categorias = [
    'Combustível',
    'Manutenção',
    'Estacionamento',
    'Alimentação',
    'Outros'
  ];
  final List<String> formasPagamento = [
    'Dinheiro',
    'Cartão de débito',
    'Cartão de crédito',
    'Pix'
  ];

  String? categoria;
  DateTime? data;
  String? formaPagamento;
  late bool isEditing;

  static const _kAccent = Color.fromARGB(255, 248, 151, 33);

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

  void _applyTemplate(Template? template) {
    if (template == null) {
      setState(() {
        categoria = null;
        _valorController.clear();
        data = null;
        formaPagamento = null;
        _observacoesController.clear();
      });
      return;
    }

    final p = template.payload;
    setState(() {
      final cat = p['categoria'] as String?;
      categoria = (cat != null && categorias.contains(cat)) ? cat : null;

      final val = p['valor'];
      _valorController.text =
          val != null ? (val as double).toStringAsFixed(2) : '';

      final dateValue = p['data'];
      data = (dateValue == null || dateValue == 'today')
          ? DateTime.now()
          : DateTime.tryParse(dateValue as String) ?? DateTime.now();

      final fp = p['formaPagamento'] as String?;
      formaPagamento =
          (fp != null && formasPagamento.contains(fp)) ? fp : null;

      _observacoesController.text = p['observacoes'] as String? ?? '';
    });
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'categoria': categoria,
      'valor': double.tryParse(_valorController.text),
      'data': 'today',
      'formaPagamento': formaPagamento,
      'observacoes': _observacoesController.text.isEmpty
          ? null
          : _observacoesController.text,
    };
  }

  Future<void> _saveAsTemplate() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => SaveTemplateDialog(
        suggestedName: categoria != null ? '$categoria padrão' : '',
      ),
    );
    if (name == null || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _templateService.saveTemplate(Template(
      id: '',
      userId: user.uid,
      formType: FormType.despesa,
      name: name,
      createdAt: DateTime.now(),
      payload: _buildPayload(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        const SnackBar(content: Text('Modelo salvo!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(widget.rootContext).size.height * 0.75,
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
                      color: Colors.grey.shade200, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                isEditing ? 'Editar Despesa' : 'Adicionar Despesa',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            if (!isEditing) ...[
              Row(
                children: [
                  Text('Modelos:',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TemplateChipRow(
                      formType: FormType.despesa,
                      templateService: _templateService,
                      onTemplateSelected: _applyTemplate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Categoria
            DropdownButtonFormField<String>(
              value: categoria,
              decoration: InputDecoration(
                hintText: 'Categoria',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
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
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  data != null
                      ? DateFormat('dd/MM/yyyy').format(data!)
                      : 'Data da despesa',
                  style:
                      TextStyle(color: data != null ? Colors.black : Colors.grey),
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: formasPagamento
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
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
                      side: const BorderSide(color: _kAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: _kAccent)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final valorDouble =
                          double.tryParse(_valorController.text);
                      if (categoria != null &&
                          valorDouble != null &&
                          data != null &&
                          formaPagamento != null) {
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
                          const SnackBar(
                              content: Text(
                                  'Por favor, preencha todos os campos obrigatórios.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: _kAccent),
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEditing ? 'Salvar' : 'Adicionar',
                        style: const TextStyle(color: _kAccent)),
                  ),
                ),
                if (!isEditing) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    color: _kAccent,
                    tooltip: 'Salvar como modelo',
                    onPressed: _saveAsTemplate,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
