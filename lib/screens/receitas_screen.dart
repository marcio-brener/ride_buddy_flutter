import 'package:flutter/material.dart';

class ReceitasScreen extends StatefulWidget {
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
    },
    {
      "app": "iFood",
      "value": 32.00,
      "distancia": 7.8,
      "localSaida": "Restaurante no Centro",
      "localEntrada": "Planejada I",
    },
    {
      "app": "99Pop",
      "value": 27.75,
      "distancia": 6.4,
      "localSaida": "Lago do Taboão",
      "localEntrada": "Vila Aparecida",
    },
    {
      "app": "Uber Black",
      "value": 80.00,
      "distancia": 18.2,
      "localSaida": "Bragança Garden Shopping",
      "localEntrada": "Jardim São Miguel",
    },
    {
      "app": "Rappi",
      "value": 22.50,
      "distancia": 5.9,
      "localSaida": "Supermercado União - Centro",
      "localEntrada": "Jardim Águas Claras",
    },
    {
      "app": "99",
      "value": 30.00,
      "distancia": 9.5,
      "localSaida": "Hospital Universitário São Francisco",
      "localEntrada": "Parque dos Estados",
    },
    {
      "app": "Uber Flash",
      "value": 18.00,
      "distancia": 4.2,
      "localSaida": "Loja no Centro",
      "localEntrada": "Bairro do Matadouro",
    },
    {
      "app": "Uber",
      "value": 40.00,
      "distancia": 10.1,
      "localSaida": "Bragança Garden Shopping",
      "localEntrada": "Centro",
    },
    {
      "app": "iFood",
      "value": 25.50,
      "distancia": 6.7,
      "localSaida": "Pizzaria Vila Rica - Centro",
      "localEntrada": "Jardim Santa Helena",
    },
    {
      "app": "Uber",
      "value": 60.00,
      "distancia": 15.4,
      "localSaida": "Estádio Nabi Abi Chedid (Bragantino)",
      "localEntrada": "Jardim São Lourenço",
    },
  ];

  double get total =>
      _receitas.fold(0, (sum, item) => sum + (item['value'] as double));

  void _addReceita() {
    String? appSelecionado;
    String value = '';
    String distancia = '';
    String localSaida = '';
    String localEntrada = '';

    final List<String> _apps = [
      "Uber",
      "99",
      "iFood",
      "Frete",
      "Rappi",
      "InDrive",
      "Uber Flash",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Receita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Aplicativo"),
                  value: appSelecionado,
                  items: _apps.map((app) {
                    return DropdownMenuItem(value: app, child: Text(app));
                  }).toList(),
                  onChanged: (val) {
                    appSelecionado = val;
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Valor'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => value = val,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Distância (km)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => distancia = val,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Local de saída'),
                  onChanged: (val) => localSaida = val,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Local de chegada'),
                  onChanged: (val) => localEntrada = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
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
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Adicionar'),
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
      appBar: AppBar(
        title: Text(
          'Receitas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 248, 151, 33),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _receitas.length,
        separatorBuilder: (context, index) =>
            Divider(thickness: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final item = _receitas[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            title: Text(
              item['app'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['localSaida']} → ${item['localEntrada']}"),
                SizedBox(height: 4),
                Text("Distância: ${item['distancia']} km"),
              ],
            ),
            trailing: Text(
              'R\$ ${item['value'].toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
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
                backgroundColor: Color.fromARGB(255, 248, 151, 33),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
