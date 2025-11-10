import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/services/despesa_service.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/despesa_list_item.dart';
import 'package:ride_buddy_flutter/widgets/despesas_modal.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/models/despesa.dart';
import 'package:ride_buddy_flutter/models/data_repository.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  final DespesaService _despesaService = DespesaService();

  void _openDespesaModal({Despesa? despesa}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DespesasModal(
          rootContext: context,
          despesaToEdit: despesa,
          onSave: (data) async {
            final bool isEditing = despesa != null;

            final despesaParaSalvar = Despesa(
              id: despesa?.id,
              categoria: data['categoria'],
              valor: data['valor'],
              data: data['data'],
              formaPagamento: data['formaPagamento'],
              observacoes: data['observacoes'],
            );

            try {
              if (isEditing) {
                await _despesaService.updateDespesa(despesaParaSalvar);
              } else {
                await _despesaService.addDespesa(despesaParaSalvar);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar despesa: $e')),
              );
            }
          },
        );
      },
    );
  }

  void _deleteDespesa(String despesaId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),

          title: const Text(
            'Excluir Despesa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: const Text(
            'Tem certeza que deseja excluir esta despesa? Esta ação não pode ser desfeita.',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () async {
                try {
                  await _despesaService.deleteDespesa(despesaId);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir despesa: $e')),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Excluir'),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Despesas"),
      body: StreamBuilder<List<Despesa>>(
        stream: _despesaService.getDespesas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar despesas: ${snapshot.error}'),
            );
          }

          double total = 0.0;
          List<Despesa> despesas = [];

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            despesas = snapshot.data!;
            total = despesas.fold(0.0, (sum, item) => sum + item.valor);
          }
          return Column(
            children: [
              Expanded(
                child: despesas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma despesa adicionada ainda.\nClique em "Adicionar" para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: despesas.length,
                        separatorBuilder: (context, index) =>
                            Divider(thickness: 1, color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          final despesa = despesas[index];
                          return DespesaListItem(
                            despesa: despesa,
                            onEdit: () => _openDespesaModal(despesa: despesa),
                            onDelete: () => _deleteDespesa(despesa.id!),
                          );
                        },
                      ),
              ),
              ButtonNavigation(
                total: total,
                callback: (ctx) => _openDespesaModal(),
              ),
            ],
          );
        },
      ),
    );
  }
}
