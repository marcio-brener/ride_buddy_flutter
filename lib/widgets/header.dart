import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const Header({super.key, required this.text});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              child: Text(
                text, // Agora o título vem da propriedade
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
