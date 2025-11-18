import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nomeController = TextEditingController();
  final _metaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _kmLitroController = TextEditingController();
  final _oleoIntervaloController = TextEditingController();
  final _kmAtualController = TextEditingController();

  String? _currentFotoUrl; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _userService.getUserProfile();
      _currentFotoUrl = profile.fotoUrl; 
      _nomeController.text = profile.nome;
      _metaController.text = profile.meta.toStringAsFixed(2);
      _modeloController.text = profile.modeloVeiculo;
      _kmLitroController.text = profile.kmPorLitro.toString();
      _oleoIntervaloController.text = profile.intervaloTrocaOleo.toString();
      _kmAtualController.text = profile.kmAtual.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar perfil: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final String? userId = _userService.currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro: Usuário não identificado. Faça login novamente."),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    setState(() => _isLoading = true);
    
    try {
      final profile = UserProfile(
        id: userId,
        nome: _nomeController.text,
        meta: double.tryParse(_metaController.text) ?? 0,
        modeloVeiculo: _modeloController.text,
        kmPorLitro: double.tryParse(_kmLitroController.text) ?? 0,
        intervaloTrocaOleo: int.tryParse(_oleoIntervaloController.text) ?? 0,
        kmAtual: int.tryParse(_kmAtualController.text) ?? 0,
        
        fotoUrl: _currentFotoUrl, 
      );

      await _userService.saveUserProfile(profile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao salvar: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(text: "Meu Perfil"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dados do Motorista",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _nomeController, label: "Nome Completo"),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _metaController,
                        label: "Meta Mensal (R\$)",
                        isNumber: true),
                    
                    const SizedBox(height: 25),
                    const Text("Dados do Veículo",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _modeloController,
                        label: "Modelo (Ex: Gol 1.6)"),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _kmLitroController,
                        label: "Consumo Médio (Km/L)",
                        isNumber: true),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _oleoIntervaloController,
                        label: "Intervalo Troca de Óleo (Km)",
                        isNumber: true),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _kmAtualController,
                        label: "Hodômetro Atual (Km)",
                        isNumber: true),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 248, 151, 33),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Salvar Alterações",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        return null;
      },
    );
  }
}