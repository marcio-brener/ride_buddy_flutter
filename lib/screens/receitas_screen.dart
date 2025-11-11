import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/receita.dart';
import 'package:ride_buddy_flutter/services/receita_service.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/receita_list_item.dart';
import 'package:ride_buddy_flutter/widgets/receita_modal.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {

  final ReceitaService _receitaService = ReceitaService();

  final List<String> _appsDisponiveis = const [
    "Uber",
    "99",
    "99Pop",
    "iFood",
    "Rappi",
    "VRDrive",
  ];

  void _openReceitaModal({Receita? receita}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return ReceitaModal(
          rootContext: context,
          receitaToEdit: receita,
          apps: _appsDisponiveis,
          onSave: (data) async {
            final bool isEditing = receita != null;

            final receitaParaSalvar = Receita(
              id: receita?.id, 
              app: data['app'],
              value: data['value'],
              distancia: data['distancia'],
              localSaida: data['localSaida'],
              localEntrada: data['localEntrada'],
              dataHora: data['dataHora'],
            );

            try {
              if (isEditing) {
                // Chama o serviço de UPDATE
                await _receitaService.updateReceita(receitaParaSalvar);
              } else {
                // Chama o serviço de CREATE
                await _receitaService.addReceita(receitaParaSalvar);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar receita: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  void _deleteReceita(String receitaId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Excluir Receita',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Tem certeza que deseja excluir esta receita? Esta ação não pode ser desfeita.'),
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
                  await _receitaService.deletaReceita(receitaId);
                } catch (e) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Erro ao excluir receita: $e')),
                     );
                   }
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Excluir'),
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Receitas"),
      body: StreamBuilder<List<Receita>>(
        stream: _receitaService.getReceitas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar receitas: ${snapshot.error}'));
          }

          double total = 0.0;
          List<Receita> receitas = [];

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            receitas = snapshot.data!;
            total = receitas.fold(0.0, (sum, item) => sum + item.value);
          }

          return Column(
            children: [
              Expanded(
                child: receitas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma receita adicionada ainda.\nClique em "Adicionar" para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: receitas.length,
                        separatorBuilder: (context, index) =>
                            Divider(thickness: 1, color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          final receita = receitas[index];
                          return ReceitaListItem(
                            receita: receita,
                            onEdit: () => _openReceitaModal(receita: receita),
                            onDelete: () => _deleteReceita(receita.id!),
                          );
                        },
                      ),
              ),
              ButtonNavigation(
                total: total,
                callback: (ctx) => _openReceitaModal(), 
              ),
            ],
          );
        },
      ),
    );
  }
}