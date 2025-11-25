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

  // Controllers
  final _nomeController = TextEditingController();
  final _metaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _consumoController = TextEditingController();
  final _oleoIntervaloController = TextEditingController(); 
  final _kmController = TextEditingController();
  
  // NOVOS CONTROLLERS (Preço e KM Alvo)
  final _precoGasolinaController = TextEditingController(); 
  final _trocaOleoAlvoController = TextEditingController();
  final _trocaPneuAlvoController = TextEditingController();

  // Dados temporários (para foto)
  String? _fotoBase64;
  
  // Constantes de fallback
  static const double _defaultMeta = 4000.0;
  static const int _defaultOleoInterval = 10000;
  static const int _defaultPneuInterval = 50000; 

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _metaController.dispose();
    _modeloController.dispose();
    _consumoController.dispose();
    _oleoIntervaloController.dispose();
    _kmController.dispose();
    _precoGasolinaController.dispose();
    _trocaOleoAlvoController.dispose();
    _trocaPneuAlvoController.dispose();
    super.dispose();
  }

  /// Função para avançar para a próxima página do wizard.
  void _nextPage() {
    if (_currentPage == 0) {
      if (_nomeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("O nome é obrigatório para prosseguir.")),
        );
        return;
      }
    } 
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, imageQuality: 70);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _fotoBase64 = base64Encode(bytes);
      });
    }
  }

  /// Coleta dados, persiste no Firebase e finaliza o fluxo de onboarding.
  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      final uid = _userService.currentUserId;
      if (uid == null) throw Exception("Sessão expirada. Faça login novamente.");
      
      // Coleta de dados
      final double meta = double.tryParse(_metaController.text) ?? _defaultMeta;
      final double consumo = double.tryParse(_consumoController.text) ?? 0.0;
      final int oleoIntervalo = int.tryParse(_oleoIntervaloController.text) ?? _defaultOleoInterval;
      final int kmAtual = int.tryParse(_kmController.text) ?? 0;
      final double precoGasolina = double.tryParse(_precoGasolinaController.text) ?? 0.0;
      
      // Se KM Alvo não for preenchido, usa o KM Atual + Intervalo Padrão
      final int trocaOleoAlvo = int.tryParse(_trocaOleoAlvoController.text) ?? (kmAtual + oleoIntervalo);
      final int trocaPneuAlvo = int.tryParse(_trocaPneuAlvoController.text) ?? (kmAtual + _defaultPneuInterval);

      final profile = UserProfile(
        id: uid,
        nome: _nomeController.text.isEmpty ? "Motorista" : _nomeController.text,
        fotoUrl: _fotoBase64,
        meta: meta,
        modeloVeiculo: _modeloController.text,
        kmPorLitro: consumo,
        intervaloTrocaOleo: oleoIntervalo,
        kmAtual: kmAtual,
        
        // NOVOS DADOS SALVOS
        precoGasolinaAtual: precoGasolina, 
        proximaTrocaOleoKm: trocaOleoAlvo,
        proximaTrocaPneuKm: trocaPneuAlvo,
        isSetupComplete: true, // MARCA COMO CONCLUÍDO
      );

      await _userService.saveUserProfile(profile);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
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
                physics: const NeverScrollableScrollPhysics(), 
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
                    const SizedBox(), 

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

  // --- 1: PERFIL (Nome e Foto) ---
  Widget _buildStep1Perfil() {
    ImageProvider? imageProvider;
    if (_fotoBase64 != null) {
      imageProvider = MemoryImage(base64Decode(_fotoBase64!));
    }

    return SingleChildScrollView(
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

  // --- 2: META E CUSTOS DE COMBUSTÍVEL ---
  Widget _buildStep2Meta() {
    const TextStyle largeGreenStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.track_changes, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text("Objetivo e Custos", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // Seção Meta
          const Text("Meta Mensal (Líquido)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text("R\$ ", style: largeGreenStyle),
              IntrinsicWidth( 
                child: TextField(
                  controller: _metaController,
                  keyboardType: TextInputType.number,
                  style: largeGreenStyle, 
                  decoration: const InputDecoration(hintText: "4000", border: InputBorder.none),
                ),
              ),
            ],
          ),
          
          const Divider(height: 40),

          // Seção Preço Gasolina
          _buildSimpleField("Preço Atual da Gasolina (R\$)", _precoGasolinaController, 
            isNumber: true, hint: "Ex: 5.49", icon: Icons.local_gas_station),
        ],
      ),
    );
  }

  // --- 3: VEÍCULO E MANUTENÇÃO ---
  Widget _buildStep3Veiculo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sobre seu veículo", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Essencial para cálculos de desgaste e alertas.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 30),
          
          _buildSimpleField("Modelo do Carro", _modeloController, hint: "Ex: Onix 1.0", icon: Icons.directions_car),
          const SizedBox(height: 20),
          _buildSimpleField("Consumo Médio (Km/L)", _consumoController, isNumber: true, hint: "Ex: 12.5", icon: Icons.speed),
          const SizedBox(height: 20),
          _buildSimpleField("Hodômetro Atual (Km)", _kmController, isNumber: true, hint: "Ex: 54000", icon: Icons.score),
          const SizedBox(height: 20),

          // Alvo de Troca de Óleo
          _buildSimpleField("KM ALVO Próxima Troca de Óleo", _trocaOleoAlvoController, 
            isNumber: true, hint: "Ex: 60000", icon: Icons.oil_barrel),
          const SizedBox(height: 20),

          // Alvo de Troca de Pneu
          _buildSimpleField("KM ALVO Próxima Troca de Pneu", _trocaPneuAlvoController, 
            isNumber: true, hint: "Ex: 104000", icon: Icons.tire_repair),
          const SizedBox(height: 20),

          // Intervalo para fins informativos (opcional)
          _buildSimpleField("Intervalo Padrão de Troca de Óleo (Km)", _oleoIntervaloController, 
            isNumber: true, hint: "10000", icon: Icons.swap_horiz),
        ],
      ),
    );
  }

  Widget _buildSimpleField(String label, TextEditingController controller, {bool isNumber = false, String? hint, IconData? icon}) {
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
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
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