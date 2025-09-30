import 'package:flutter/material.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final List<Map<String, dynamic>> _receitas = [
    {
      "app": "Uber",
      "value": 45.50,
      "distancia": 12.3,
      "localSaida": "Terminal Rodoviário Bragança Paulista",
      "localEntrada": "Jardim do Lago",
      "dataHora": DateTime.now(),
    },
    {
      "app": "iFood",
      "value": 32.00,
      "distancia": 7.8,
      "localSaida": "Restaurante no Centro",
      "localEntrada": "Planejada I",
      "dataHora": DateTime.now(),
    },
    {
      "app": "99Pop",
      "value": 27.75,
      "distancia": 6.4,
      "localSaida": "Lago do Taboão",
      "localEntrada": "Vila Aparecida",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Rappi",
      "value": 22.50,
      "distancia": 5.9,
      "localSaida": "Supermercado União - Centro",
      "localEntrada": "Jardim Águas Claras",
      "dataHora": DateTime.now(),
    },
    {
      "app": "99",
      "value": 30.00,
      "distancia": 9.5,
      "localSaida": "Hospital Universitário São Francisco",
      "localEntrada": "Parque dos Estados",
      "dataHora": DateTime.now(),
    },
    {
      "app": "VRDrive",
      "value": 18.00,
      "distancia": 4.2,
      "localSaida": "Loja no Centro",
      "localEntrada": "Bairro do Matadouro",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Uber",
      "value": 40.00,
      "distancia": 10.1,
      "localSaida": "Bragança Garden Shopping",
      "localEntrada": "Centro",
      "dataHora": DateTime.now(),
    },
    {
      "app": "iFood",
      "value": 25.50,
      "distancia": 6.7,
      "localSaida": "Pizzaria Vila Rica - Centro",
      "localEntrada": "Jardim Santa Helena",
      "dataHora": DateTime.now(),
    },
    {
      "app": "Uber",
      "value": 60.00,
      "distancia": 15.4,
      "localSaida": "Estádio Nabi Abi Chedid (Bragantino)",
      "localEntrada": "Jardim São Lourenço",
      "dataHora": DateTime.now(),
    },
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
      _receitas.fold(0, (sum, item) => sum + (item['value'] as double));

  void _addReceita() {
    String? appSelecionado;
    String value = '';
    String distancia = '';
    String localSaida = '';
    String localEntrada = '';
    DateTime? dataHora;

    final List<String> _apps = [
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
                      value: appSelecionado,
                      items: _apps.map((app) {
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
                        _receitas.add({
                          'app': appSelecionado,
                          'value': double.tryParse(value) ?? 0,
                          'distancia': double.tryParse(distancia) ?? 0,
                          'localSaida': localSaida,
                          'localEntrada': localEntrada,
                          'dataHora': dataHora ?? DateTime.now(),
                        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        backgroundColor: const Color.fromARGB(255, 248, 151, 33),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Voltar  ', style: TextStyle(fontSize: 14)),
              ),
            ),
            Expanded(
              child: Center(
                child: const Text(
                  'Receitas',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _receitas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _receitas[index];
          // Correção: se dataHora for null, usa DateTime.now()
          final DateTime dataHora = item['dataHora'] ?? DateTime.now();

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: appLogos[item['app']] != null
                ? Image.asset(appLogos[item['app']]!, width: 40, height: 40)
                : null,
            title: Text(
              item['app'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['localSaida']} → ${item['localEntrada']}"),
                const SizedBox(height: 4),
                Text("Distância: ${item['distancia']} km"),
                const SizedBox(height: 2),
                Text(
                  "Data/Hora: ${dataHora.day}/${dataHora.month}/${dataHora.year} ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            trailing: Text(
              'R\$ ${item['value'].toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        decoration: BoxDecoration(color: Colors.white, border: Border()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addReceita,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: const Color.fromARGB(255, 248, 151, 33),
                padding: const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 16,
                ),
              ),
              child: const Text(
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
