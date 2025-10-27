import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o pacote de autenticação

// Enum para controlar facilmente o estado do formulário
enum AuthMode { Login, Register }

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  // Novo estado para controlar se estamos em modo Login ou Cadastro
  AuthMode _authMode = AuthMode.Login;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Variável para controlar o estado de "carregando"
  bool _isLoading = false;

  // Método unificado para lidar com Login e Cadastro
  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Lógica de Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      } else {
        // Lógica de Cadastro
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      }
      
      // Se a autenticação for bem sucedida,
      // o StreamBuilder no "AuthGate" e
      // vai automaticamente navegar para a HomeScreen.
      // Não precisamos mais do Navigator.pushReplacement .

    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase
      String message = "Ocorreu um erro. Tente novamente.";
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta. Tente novamente.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso. Tente fazer login.';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca.';
      }
      
      // Garante que o widget ainda está na árvore antes de mostrar o SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Trata outros erros genéricos
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ocorreu um erro inesperado."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Finaliza o estado de carregamento, mesmo se der erro
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para trocar entre os modos de Login e Cadastro
  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.Login ? AuthMode.Register : AuthMode.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress, // Melhora a usabilidade
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
        SizedBox(height: 20),
        
        // Se estiver carregando, mostra um indicador de progresso, senão, mostra o botão
        if (_isLoading)
          CircularProgressIndicator()
        else
          SizedBox(
            height: 50,
            width: 200,
            child: ElevatedButton(
              onPressed: _submit, // Chama o método _submit
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 248, 151, 33),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                // O texto do botão muda de acordo com o modo
                _authMode == AuthMode.Login ? "Entrar" : "Criar Conta",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        SizedBox(height: 20),
        TextButton(
          onPressed: _switchAuthMode, // Chama o método para trocar o modo
          child: Text(
            // O texto do botão de troca também muda
            _authMode == AuthMode.Login
                ? "Novo usuário? Crie uma conta."
                : "Já tem uma conta? Faça login.",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 100.0)),
      ],
    );
  }
}