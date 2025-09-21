import 'package:flutter/material.dart';

class ReceitasScreen extends StatelessWidget {
  const ReceitasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        backgroundColor: const Color.fromARGB(255, 248, 151, 33),
      ),
      body: const Center(
        child: Text('Página de Receitas', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
