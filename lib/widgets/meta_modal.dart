import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/template.dart';
import 'package:ride_buddy_flutter/services/template_service.dart';
import 'package:ride_buddy_flutter/widgets/save_template_dialog.dart';
import 'package:ride_buddy_flutter/widgets/template_chip_row.dart';

class MetaModal extends StatefulWidget {
  final BuildContext rootContext;
  final Function(Map<String, dynamic>) onSave;
  final double currentMeta;

  const MetaModal({
    super.key,
    required this.rootContext,
    required this.onSave,
    required this.currentMeta,
  });

  @override
  State<MetaModal> createState() => _MetaModalState();
}

class _MetaModalState extends State<MetaModal> {
  final _metaController = TextEditingController();
  final _templateService = TemplateService();

  static const _kAccent = Color.fromARGB(255, 248, 151, 33);

  @override
  void initState() {
    super.initState();
    _metaController.text = widget.currentMeta.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _metaController.dispose();
    super.dispose();
  }

  void _applyTemplate(Template? template) {
    if (template == null) {
      _metaController.clear();
      return;
    }

    final val = template.payload['meta'];
    if (val != null) {
      _metaController.text = (val as double).toStringAsFixed(0);
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'meta': double.tryParse(_metaController.text),
    };
  }

  Future<void> _saveAsTemplate() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const SaveTemplateDialog(suggestedName: 'Meta padrão'),
    );
    if (name == null || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _templateService.saveTemplate(Template(
      id: '',
      userId: user.uid,
      formType: FormType.meta,
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

  void _submit() {
    final double? novaMeta = double.tryParse(_metaController.text);

    if (novaMeta != null && novaMeta > 0) {
      widget.onSave({'meta': novaMeta});
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um valor válido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Definir Nova Meta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Row(
              children: [
                Text('Modelos:',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 8),
                Expanded(
                  child: TemplateChipRow(
                    formType: FormType.meta,
                    templateService: _templateService,
                    onTemplateSelected: _applyTemplate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _metaController,
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: 'Valor da Meta',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: _kAccent),
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Salvar',
                        style: TextStyle(color: _kAccent)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  color: _kAccent,
                  tooltip: 'Salvar como modelo',
                  onPressed: _saveAsTemplate,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
