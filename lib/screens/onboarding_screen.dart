import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  int _currentPage = 0;
  bool _isLoading = false;

  // Dados temporários
  String _nome = "";
  String? _fotoBase64;
  double _meta = 4000.0;
  String _modelo = "";
  double _consumo = 0.0;
  int _oleo = 10000;
  int _kmAtual = 0;

  // Controllers
  final _nomeController = TextEditingController();
  final _metaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _consumoController = TextEditingController();
  final _oleoController = TextEditingController();
  final _kmController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 400, imageQuality: 70);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _fotoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      final uid = _userService.currentUserId!;
      
      // Cria o perfil completo
      final profile = UserProfile(
        id: uid,
        nome: _nomeController.text,
        fotoUrl: _fotoBase64,
        meta: double.tryParse(_metaController.text) ?? 4000,
        modeloVeiculo: _modeloController.text,
        kmPorLitro: double.tryParse(_consumoController.text) ?? 0,
        intervaloTrocaOleo: int.tryParse(_oleoController.text) ?? 10000,
        kmAtual: int.tryParse(_kmController.text) ?? 0,
        isSetupComplete: true, // MARCA COMO COMPLETO!
      );

      await _userService.saveUserProfile(profile);

      if (mounted) {
        // Vai para a Home e remove o histórico para não voltar ao onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            // Barra de Progresso Superior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(child: _buildProgressIndicator(0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProgressIndicator(1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProgressIndicator(2)),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(), // Impede deslizar manual
                children: [
                  _buildStep1Perfil(),
                  _buildStep2Meta(),
                  _buildStep3Veiculo(),
                ],
              ),
            ),
            
            // Botões de Navegação
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                         _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text("Voltar", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    const SizedBox(), // Espaço vazio para alinhar

                  ElevatedButton(
                    onPressed: _currentPage == 2 ? _finishOnboarding : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 151, 33),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      _currentPage == 2 ? "Concluir" : "Próximo",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int index) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: index <= _currentPage 
            ? const Color.fromARGB(255, 248, 151, 33) 
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // --- PASSO 1: PERFIL ---
  Widget _buildStep1Perfil() {
    ImageProvider? imageProvider;
    if (_fotoBase64 != null) {
      imageProvider = MemoryImage(base64Decode(_fotoBase64!));
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Vamos começar!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Como você gostaria de ser chamado?", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: imageProvider,
                  child: _fotoBase64 == null 
                    ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nomeController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "Seu Nome",
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  // --- PASSO 2: META ---
  Widget _buildStep2Meta() {
  const TextStyle largeGreenStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.track_changes, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text("Qual é o seu objetivo?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Defina quanto você quer ganhar por mês.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic, 
            children: [
              const Text("R\$ ", style: largeGreenStyle), 
              IntrinsicWidth( 
                child: TextField(
                  controller: _metaController,
                  keyboardType: TextInputType.number,
                  style: largeGreenStyle, 
                  decoration: const InputDecoration(
                    hintText: "4000",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- PASSO 3: VEÍCULO ---
  Widget _buildStep3Veiculo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sobre seu veículo", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Isso ajuda a calcular seus custos reais.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 30),
          
          _buildSimpleField("Modelo do Carro", _modeloController, hint: "Ex: Onix 1.0"),
          const SizedBox(height: 20),
          _buildSimpleField("Consumo Médio (Km/L)", _consumoController, isNumber: true, hint: "Ex: 12.5"),
          const SizedBox(height: 20),
          _buildSimpleField("Troca de Óleo a cada (Km)", _oleoController, isNumber: true, hint: "Padrão: 10000"),
          const SizedBox(height: 20),
          _buildSimpleField("Hodômetro Atual (Km)", _kmController, isNumber: true, hint: "Ex: 54000"),
        ],
      ),
    );
  }

  Widget _buildSimpleField(String label, TextEditingController controller, {bool isNumber = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}