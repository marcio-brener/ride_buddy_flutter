import 'package:flutter/material.dart';

class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: const Color.fromARGB(255, 248, 151, 33),
      ),
      body: const Center(
        child: Text('Página de Relatórios', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
