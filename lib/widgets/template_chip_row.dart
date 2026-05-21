import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/template.dart';
import 'package:ride_buddy_flutter/services/template_service.dart';

const _kAccent = Color.fromARGB(255, 248, 151, 33);
const _kChipLimit = 4;

class TemplateChipRow extends StatefulWidget {
  final FormType formType;
  final TemplateService templateService;
  final void Function(Template?) onTemplateSelected;

  const TemplateChipRow({
    super.key,
    required this.formType,
    required this.templateService,
    required this.onTemplateSelected,
  });

  @override
  State<TemplateChipRow> createState() => _TemplateChipRowState();
}

class _TemplateChipRowState extends State<TemplateChipRow> {
  List<Template> _templates = [];
  String? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates =
        await widget.templateService.getTemplates(widget.formType);
    if (!mounted) return;
    setState(() {
      _templates = templates;
      _loading = false;
    });

    final defaultTemplate = templates.where((t) => t.isDefault).firstOrNull;
    if (defaultTemplate != null) {
      setState(() => _selectedId = defaultTemplate.id);
      widget.onTemplateSelected(defaultTemplate);
    }
  }

  void _selectTemplate(Template? template) {
    setState(() => _selectedId = template?.id);
    widget.onTemplateSelected(template);
    if (template != null) {
      widget.templateService.incrementUsage(template.id);
    }
  }

  Future<void> _deleteTemplate(Template t) async {
    await widget.templateService.deleteTemplate(t.id);
    if (_selectedId == t.id) _selectTemplate(null);
    _loadTemplates();
  }

  Future<void> _toggleDefault(Template t) async {
    await widget.templateService
        .setDefault(widget.formType, t.isDefault ? null : t.id);
    _loadTemplates();
  }

  void _showChipMenu(Template t) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                t.isDefault ? Icons.star_outline : Icons.star,
                color: _kAccent,
              ),
              title: Text(
                  t.isDefault ? 'Remover como padrão' : 'Definir como padrão'),
              onTap: () {
                Navigator.pop(ctx);
                _toggleDefault(t);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Excluir',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteTemplate(t);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllTemplates() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Todos os modelos',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._templates.map(
              (t) => ListTile(
                leading: t.isDefault
                    ? const Icon(Icons.star, color: Colors.amber)
                    : const Icon(Icons.bookmark_outline, color: Colors.grey),
                title: Text(t.name),
                subtitle: Text(
                  'Usado ${t.usageCount} ${t.usageCount == 1 ? 'vez' : 'vezes'}',
                ),
                selected: _selectedId == t.id,
                selectedTileColor: _kAccent.withAlpha(20),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    Navigator.pop(ctx);
                    if (action == 'default') _toggleDefault(t);
                    if (action == 'delete') _deleteTemplate(t);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'default',
                      child: Text(t.isDefault
                          ? 'Remover como padrão'
                          : 'Definir como padrão'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _selectTemplate(t);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
          ),
        ),
      );
    }

    final visibleTemplates = _templates.take(_kChipLimit).toList();
    final hasMore = _templates.length > _kChipLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_templates.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Salve um modelo após preencher o formulário',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TemplateChip(
                label: '+ Em branco',
                selected: _selectedId == null,
                onTap: () => _selectTemplate(null),
              ),
              ...visibleTemplates.map(
                (t) => _TemplateChip(
                  label: t.name,
                  selected: _selectedId == t.id,
                  isDefault: t.isDefault,
                  onTap: () => _selectTemplate(t),
                  onLongPress: () => _showChipMenu(t),
                ),
              ),
              if (hasMore)
                _TemplateChip(
                  label: 'Ver todos (${_templates.length})',
                  selected: false,
                  onTap: _showAllTemplates,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _TemplateChip({
    required this.label,
    required this.selected,
    this.isDefault = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Chip(
          avatar: isDefault
              ? const Icon(Icons.star, color: Colors.amber, size: 16)
              : null,
          label: Text(label),
          backgroundColor: selected ? _kAccent : Colors.grey.shade200,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 12,
          ),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
        ),
      ),
    );
  }
}
