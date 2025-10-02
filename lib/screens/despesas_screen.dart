import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final List<Despesa> _despesas = [
    Despesa(
      categoria: 'Combustível',
      valor: 145.50,
      data: DateTime(2025, 9, 10),
      formaPagamento: 'Cartão de débito',
      observacoes: 'Abastecimento no Posto Shell - Centro',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 270.00,
      data: DateTime(2025, 9, 5),
      formaPagamento: 'Pix',
      observacoes: 'Troca de óleo na AutoCenter Bragança Paulista',
    ),
    Despesa(
      categoria: 'Estacionamento',
      valor: 35.00,
      data: DateTime(2025, 9, 12),
      formaPagamento: 'Dinheiro',
      observacoes: 'Estacionamento no Shopping Bragança Garden',
    ),
    Despesa(
      categoria: 'Alimentação',
      valor: 60.90,
      data: DateTime(2025, 9, 11),
      formaPagamento: 'Cartão de crédito',
      observacoes: 'Almoço com cliente no Restaurante Dona Chica',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 850.00,
      data: DateTime(2025, 9, 3),
      formaPagamento: 'Pix',
      observacoes: 'Troca de pneus dianteiros na Pneus Bragança',
    ),
    Despesa(
      categoria: 'Combustível',
      valor: 130.00,
      data: DateTime(2025, 9, 15),
      formaPagamento: 'Cartão de crédito',
      observacoes: 'Abastecimento no Posto Ipiranga - Jardim do Lago',
    ),
    Despesa(
      categoria: 'Estacionamento',
      valor: 45.00,
      data: DateTime(2025, 9, 16),
      formaPagamento: 'Dinheiro',
      observacoes: 'Estacionamento próximo ao Terminal Rodoviário',
    ),
    Despesa(
      categoria: 'Alimentação',
      valor: 23.50,
      data: DateTime(2025, 9, 14),
      formaPagamento: 'Dinheiro',
      observacoes: 'Lanche rápido na Lanchonete McDonald\'s - Centro',
    ),
    Despesa(
      categoria: 'Manutenção',
      valor: 50.00,
      data: DateTime(2025, 9, 13),
      formaPagamento: 'Pix',
      observacoes: 'Lavagem completa no Lava Rápido Bragança Paulista',
    ),
    Despesa(
      categoria: 'Combustível',
      valor: 140.00,
      data: DateTime(2025, 9, 18),
      formaPagamento: 'Cartão de débito',
      observacoes: 'Abastecimento no Posto Petrobras - Centro',
    ),
  ];

  double get total => _despesas.fold(0, (sum, item) => sum + item.valor);

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

  void _addDespesa(BuildContext rootContext) {
    String valor = '';
    String? categoria;
    DateTime? data;
    String? formaPagamento;
    String observacoes = '';

    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height: MediaQuery.of(rootContext).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Botão de fechar
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

                    // Categoria
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
                      onChanged: (val) {
                        setStateSheet(() {
                          categoria = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Valor
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
                      onChanged: (val) {
                        setStateSheet(() {
                          valor = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Data
                    GestureDetector(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: rootContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setStateSheet(() {
                            data = selectedDate;
                          });
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

                    // Forma de pagamento
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
                      onChanged: (val) {
                        setStateSheet(() {
                          formaPagamento = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Observações
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
                      onChanged: (val) {
                        setStateSheet(() {
                          observacoes = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 248, 151, 33)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancelar',
                              style:
                                  TextStyle(color: Color.fromARGB(255, 248, 151, 33)),
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
                                ScaffoldMessenger.of(rootContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Por favor, preencha todos os campos obrigatórios.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _despesas.add(Despesa(
                                  categoria: categoria!,
                                  valor: valorDouble,
                                  data: data!,
                                  formaPagamento: formaPagamento!,
                                  observacoes: observacoes,
                                ));
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
                              style:
                                  TextStyle(color: Color.fromARGB(255, 248, 151, 33)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Despesas"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _despesas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _despesas[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(item.categoria),
            subtitle: Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(item.data)}\n'
              'Forma: ${item.formaPagamento}${item.observacoes.isNotEmpty ? "\nObs: ${item.observacoes}" : ""}',
            ),
            trailing: Text('R\$ ${item.valor.toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: _addDespesa,
      ),
    );
  }
}