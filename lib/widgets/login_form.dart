import 'package:flutter/material.dart';
import '/models/login.dart';
import '/screens/home_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _login(BuildContext context) {
    final login = Login(
      username: _userController.text,
      password: _passController.text,
    );

    if (login.username == "" && login.password == "") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login falhou! Verifique suas credenciais.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _userController,
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.email),
            filled: true,
            fillColor: const Color.fromARGB(139, 201, 201, 201),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            labelText: "Senha",
            prefixIcon: Icon(Icons.lock),
            filled: true,
            fillColor: const Color.fromARGB(139, 201, 201, 201),
          ),

          obscureText: true,
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: EdgeInsets.all(16),
          ),
          child: Text(
            "Esqueci a senha",
            style: TextStyle(
              color: Color.fromARGB(255, 248, 151, 33),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            onPressed: () => _login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 248, 151, 33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "Entrar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 150.0)),
        SizedBox(
          height: 20,
          child: Text("Novo Usuário? Clique aqui para criar uma conta."),
        ),
      ],
    );
  }
}
