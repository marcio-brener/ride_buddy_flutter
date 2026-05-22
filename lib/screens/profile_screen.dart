import 'package:flutter/material.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';
import 'package:ride_buddy_flutter/services/notification_service.dart';
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
  final _precoGasolinaController = TextEditingController();
  final _trocaOleoAlvoController = TextEditingController();
  final _trocaPneuAlvoController = TextEditingController();
  UserProfile? _originalProfile;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadNotificationSettings();
  }
  
  @override
  void dispose() {
    _nomeController.dispose();
    _metaController.dispose();
    _modeloController.dispose();
    _kmLitroController.dispose();
    _oleoIntervaloController.dispose();
    _kmAtualController.dispose();
    _precoGasolinaController.dispose();
    _trocaOleoAlvoController.dispose();
    _trocaPneuAlvoController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isReminderEnabled();
    final time = await _notificationService.getReminderTime();
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = time;
      });
    }
  }

  Future<void> _onReminderToggle(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return;
      await _notificationService.scheduleEndOfDayReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await _notificationService.cancelEndOfDayReminder();
    }
    if (mounted) setState(() => _reminderEnabled = value);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
      await _notificationService.scheduleEndOfDayReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _userService.getUserProfile();
      
      // ARMAZENA O PERFIL ORIGINAL: _currentFotoUrl é acessível via _originalProfile!.fotoUrl
      _originalProfile = profile; 
      _nomeController.text = profile.nome;
      _metaController.text = profile.meta.toStringAsFixed(2);
      _modeloController.text = profile.modeloVeiculo;
      _kmLitroController.text = profile.kmPorLitro.toString();
      _oleoIntervaloController.text = profile.intervaloTrocaOleo.toString();
      _kmAtualController.text = profile.kmAtual.toString();
      _precoGasolinaController.text = profile.precoGasolinaAtual.toStringAsFixed(2);
      _trocaOleoAlvoController.text = profile.proximaTrocaOleoKm.toString();
      _trocaPneuAlvoController.text = profile.proximaTrocaPneuKm.toString();
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

    if (userId == null || _originalProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro: Recarregue a tela ou faça login novamente."),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    setState(() => _isLoading = true);
    
    try {
      final novoPerfil = _originalProfile!.copyWith(
        nome: _nomeController.text,
        meta: double.tryParse(_metaController.text) ?? 0,
        modeloVeiculo: _modeloController.text,
        kmPorLitro: double.tryParse(_kmLitroController.text) ?? 0,
        intervaloTrocaOleo: int.tryParse(_oleoIntervaloController.text) ?? 0,
        kmAtual: int.tryParse(_kmAtualController.text) ?? 0,
        precoGasolinaAtual: double.tryParse(_precoGasolinaController.text) ?? 0,
        proximaTrocaOleoKm: int.tryParse(_trocaOleoAlvoController.text) ?? 0,
        proximaTrocaPneuKm: int.tryParse(_trocaPneuAlvoController.text) ?? 0,
      );

      await _userService.saveUserProfile(novoPerfil);
      
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
                        controller: _precoGasolinaController,
                        label: "Preço Atual da Gasolina (R\$)",
                        isNumber: true),
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
                      
                    const SizedBox(height: 25),

                    const Text("Alvos de Próxima Manutenção",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _trocaOleoAlvoController,
                        label: "KM Alvo Próxima Troca de Óleo",
                        isNumber: true),
                    const SizedBox(height: 10),
                    _buildTextField(
                        controller: _trocaPneuAlvoController,
                        label: "KM Alvo Próxima Troca de Pneu",
                        isNumber: true),

                    const SizedBox(height: 25),
                    const Text(
                      'Notificações',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildNotificationSection(),
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

  Widget _buildNotificationSection() {
    final String timeLabel =
        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Lembrete no fim do dia'),
            subtitle: const Text('Aviso diário para registrar sua jornada'),
            value: _reminderEnabled,
            activeColor: const Color.fromARGB(255, 248, 151, 33),
            onChanged: _onReminderToggle,
          ),
          if (_reminderEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Horário do lembrete'),
              trailing: TextButton(
                onPressed: _pickReminderTime,
                child: Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 248, 151, 33),
                  ),
                ),
              ),
            ),
          ],
        ],
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