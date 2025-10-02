import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/receita.dart';
import 'package:ride_buddy_flutter/widgets/button_navigation.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/widgets/receita_list_item.dart';
import 'package:ride_buddy_flutter/widgets/receita_modal.dart';
import 'package:ride_buddy_flutter/models/data_repository.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final List<Receita> _receitas = [
    Receita(
      app: "Uber",
      value: 45.50,
      distancia: 12.3,
      localSaida: "Terminal Rodoviário Bragança Paulista",
      localEntrada: "Jardim do Lago",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "iFood",
      value: 32.00,
      distancia: 7.8,
      localSaida: "Restaurante no Centro",
      localEntrada: "Planejada I",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "99Pop",
      value: 27.75,
      distancia: 6.4,
      localSaida: "Lago do Taboão",
      localEntrada: "Vila Aparecida",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Rappi",
      value: 22.50,
      distancia: 5.9,
      localSaida: "Supermercado União - Centro",
      localEntrada: "Jardim Águas Claras",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "99",
      value: 30.00,
      distancia: 9.5,
      localSaida: "Hospital Universitário São Francisco",
      localEntrada: "Parque dos Estados",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "VRDrive",
      value: 18.00,
      distancia: 4.2,
      localSaida: "Loja no Centro",
      localEntrada: "Bairro do Matadouro",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Uber",
      value: 40.00,
      distancia: 10.1,
      localSaida: "Bragança Garden Shopping",
      localEntrada: "Centro",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "iFood",
      value: 25.50,
      distancia: 6.7,
      localSaida: "Pizzaria Vila Rica - Centro",
      localEntrada: "Jardim Santa Helena",
      dataHora: DateTime.now(),
    ),
    Receita(
      app: "Uber",
      value: 60.00,
      distancia: 15.4,
      localSaida: "Estádio Nabi Abi Chedid (Bragantino)",
      localEntrada: "Jardim São Lourenço",
      dataHora: DateTime.now(),
    ),
  ];

  final Map<String, String> appLogos = {
    "Uber": "assets/uber-logo.png",
    "99": "assets/99-logo.png",
    "99Pop": "assets/99-logo.png",
    "iFood": "assets/ifood-logo.png",
    "Rappi": "assets/rappi-logo.png",
    "VRDrive": "assets/vrdrive-logo.png",
  };

  double get total =>
   _receitas.fold(0, (sum, receita) => sum + receita.value);

  void _addReceita(BuildContext rootContext) {
    String? appSelecionado;
    String value = '';
    String distancia = '';
    String localSaida = '';
    String localEntrada = '';
    DateTime? dataHora;

    final List<String> apps = [
      "Uber",
      "99",
      "iFood",
      "Frete",
      "Rappi",
      "InDrive",
      "VRDrive",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Adicionar Receita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Aplicativo",
                      ),
                      initialValue: appSelecionado,
                      items: apps.map((app) {
                        return DropdownMenuItem(value: app, child: Text(app));
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          appSelecionado = val;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Valor'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => value = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Distância (km)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => distancia = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Local de saída',
                      ),
                      onChanged: (val) => localSaida = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Local de chegada',
                      ),
                      onChanged: (val) => localEntrada = val,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setStateDialog(() {
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
                      child: Text(
                        dataHora == null
                            ? 'Selecionar Data e Hora'
                            : '${dataHora!.day}/${dataHora!.month}/${dataHora!.year} ${dataHora!.hour.toString().padLeft(2, '0')}:${dataHora!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (appSelecionado != null &&
                        value.isNotEmpty &&
                        distancia.isNotEmpty &&
                        localSaida.isNotEmpty &&
                        localEntrada.isNotEmpty) {
                      setState(() {
                        final novaReceita = Receita(
                          app: appSelecionado!,
                          value: double.tryParse(value) ?? 0,
                          distancia: double.tryParse(distancia) ?? 0,
                          localSaida: localSaida,
                          localEntrada: localEntrada,
                          dataHora: dataHora ?? DateTime.now(),
                        );
                         _receitas.add(novaReceita);
                        DataRepository().receitas.add(novaReceita);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //função para editar receita
  void _editReceita(int index) {
    Receita receita = _receitas[index];

    String? appSelecionado = receita.app;
    String value = receita.value.toString();
    String distancia = receita.distancia.toString();
    String localSaida = receita.localSaida;
    String localEntrada = receita.localEntrada;
    DateTime? dataHora = receita.dataHora;

    final List<String> apps = [
      "Uber", "99", "iFood", "Frete", "Rappi", "InDrive", "VRDrive",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar Receita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Aplicativo"),
                      value: appSelecionado,
                      items: apps.map((app) => DropdownMenuItem(
                        value: app, child: Text(app),
                      )).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          appSelecionado = val;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Valor'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: value),
                      onChanged: (val) => value = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Distância (km)'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: distancia),
                      onChanged: (val) => distancia = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Local de saída'),
                      controller: TextEditingController(text: localSaida),
                      onChanged: (val) => localSaida = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Local de chegada'),
                      controller: TextEditingController(text: localEntrada),
                      onChanged: (val) => localEntrada = val,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dataHora ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setStateDialog(() {
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
                      child: Text(
                        dataHora == null
                            ? 'Selecionar Data e Hora'
                            : '${dataHora!.day}/${dataHora!.month}/${dataHora!.year} ${dataHora!.hour.toString().padLeft(2, '0')}:${dataHora!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (appSelecionado != null &&
                        value.isNotEmpty &&
                        distancia.isNotEmpty &&
                        localSaida.isNotEmpty &&
                        localEntrada.isNotEmpty) {
                      setState(() {
                        _receitas[index] = Receita(
                          app: appSelecionado!,
                          value: double.tryParse(value) ?? 0,
                          distancia: double.tryParse(distancia) ?? 0,
                          localSaida: localSaida,
                          localEntrada: localEntrada,
                          dataHora: dataHora ?? DateTime.now(),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //função para excluir receita
  void _deleteReceita(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Receita'),
          content: const Text('Tem certeza que deseja excluir esta receita?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _receitas.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Receitas"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _receitas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final Receita receita = _receitas[index];
          // Correção: se dataHora for null, usa DateTime.now()
          final DateTime dataHora = receita.dataHora;

          return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: appLogos[receita.app] != null
              ? Image.asset(appLogos[receita.app]!, width: 40, height: 40)
              : null,
          title: Text(
            receita.app,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${receita.localSaida} → ${receita.localEntrada}"),
              const SizedBox(height: 4),
              Text("Distância: ${receita.distancia} km"),
              const SizedBox(height: 2),
              Text(
                "Data/Hora: ${receita.dataHora.day}/${receita.dataHora.month}/${receita.dataHora.year} ${receita.dataHora.hour.toString().padLeft(2, '0')}:${receita.dataHora.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'R\$ ${receita.value.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'Editar') {
                    _editReceita(index);
                  } else if (value == 'Excluir') {
                    _deleteReceita(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Editar', child: Text('Editar')),
                  PopupMenuItem(value: 'Excluir', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        );
        },
      ),
      bottomNavigationBar: ButtonNavigation(
        total: total,
        callback: _addReceita,
      ),
    );
  }
}
