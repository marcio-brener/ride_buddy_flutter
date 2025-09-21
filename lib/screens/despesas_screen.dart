import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  final List<Map<String, dynamic>> _despesas = [];

  double get total =>
      _despesas.fold(0, (sum, item) => sum + (item['valor'] as double));

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
    String descricao = '';
    String? categoria;
    String valor = '';
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Botão de fechar centralizado
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
                          child: Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Categoria / Descrição
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
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setStateSheet(() {
                          categoria = val;
                          descricao = val ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 12),

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
                    SizedBox(height: 12),

                    // Data da despesa
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
                        padding: EdgeInsets.symmetric(horizontal: 12),
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
                    SizedBox(height: 12),

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
                          .map(
                            (f) => DropdownMenuItem(value: f, child: Text(f)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setStateSheet(() {
                          formaPagamento = val;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Observações (opcional)
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
                    SizedBox(height: 20),

                    // Botões Cancelar e Adicionar
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color.fromARGB(255, 248, 151, 33),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Color.fromARGB(255, 248, 151, 33),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              double? valorDouble = double.tryParse(valor);
                              if (descricao.isEmpty ||
                                  valor.isEmpty ||
                                  valorDouble == null ||
                                  valorDouble <= 0 ||
                                  data == null ||
                                  formaPagamento == null) {
                                // Fecha o modal
                                Navigator.pop(context);
                                // Mostra SnackBar no Scaffold principal
                                ScaffoldMessenger.of(rootContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Por favor, preencha todos os campos obrigatórios.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _despesas.add({
                                  'descricao': descricao,
                                  'categoria': categoria,
                                  'valor': valorDouble,
                                  'data': data,
                                  'formaPagamento': formaPagamento,
                                  'observacoes': observacoes,
                                });
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Color.fromARGB(255, 248, 151, 33),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Despesas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 248, 151, 33),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _despesas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _despesas[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            title: Text('${item['categoria']} - ${item['descricao']}'),
            subtitle: Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(item['data'])}\nForma: ${item['formaPagamento']}${item['observacoes'].isNotEmpty ? "\nObs: ${item['observacoes']}" : ""}',
            ),
            trailing: Text('R\$ ${item['valor'].toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _addDespesa(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Color.fromARGB(255, 248, 151, 33),
                padding: EdgeInsets.symmetric(horizontal: 55, vertical: 12),
              ),
              child: Text(
                'Adicionar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
