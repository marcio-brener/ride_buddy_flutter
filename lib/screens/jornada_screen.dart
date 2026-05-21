import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_buddy_flutter/models/jornada.dart';
import 'package:ride_buddy_flutter/models/template.dart';
import 'package:ride_buddy_flutter/services/jornada_service.dart';
import 'package:ride_buddy_flutter/services/template_service.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/widgets/header.dart';
import 'package:ride_buddy_flutter/widgets/save_template_dialog.dart';
import 'package:ride_buddy_flutter/widgets/template_chip_row.dart';

class JornadaScreen extends StatefulWidget {
  const JornadaScreen({super.key});

  @override
  State<JornadaScreen> createState() => _JornadaScreenState();
}

class _JornadaScreenState extends State<JornadaScreen> {
  final JornadaService _jornadaService = JornadaService();
  final UserService _userService = UserService();
  final JornadaController _controller = JornadaController();

  GoogleMapController? _mapController;
  StreamSubscription? _dataSubscription;

  // Variáveis de Estado da UI
  double _currentKm = 0.0;
  int _currentSeconds = 0; // Estado para o Timer
  bool _isTracking = false;
  bool _isPaused = false;


  @override
  void initState() {
    super.initState();
    // 1. Puxa os valores atuais do Singleton para inicializar o estado da UI
    _isTracking = _controller.isRunning;
    _isPaused = _controller.isPaused;
    _currentKm = _controller.distanceKm;
    _currentSeconds = _controller.seconds;
    // 2. Ouve o Stream de dados (KM, Tempo, Pausa) do serviço de background
    _dataSubscription = _controller.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          // Os dados serão puxados do Stream
          _currentKm = data['km'] as double;
          _currentSeconds = data['time'] as int;
          _isTracking = data['isRunning'] as bool;
          _isPaused = data['isPaused'] as bool;
        });
      }
    });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Função auxiliar para formatar tempo (HH:MM:SS)
  String _formatTime(int totalSeconds) {
    final int seconds = totalSeconds % 60;
    final int minutes = (totalSeconds ~/ 60) % 60;
    final int hours = (totalSeconds ~/ 3600);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- MÉTODOS DE CONTROLE DA JORNADA (FRONT-END) ---

  Future<void> _startJornada() async {
    try {
      await _jornadaService.startTracking();
      setState(() {
        _isTracking = true;
        _isPaused = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao iniciar rastreamento: $e")),
      );
    }
  }

  void _pauseJornada() {
    _jornadaService.pauseTracking();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeJornada() {
    _jornadaService.resumeTracking();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _finishJornada() async {
    final jornadaRastreada = await _jornadaService.stopTracking();
    final userProfile = await _userService.getUserProfile();

    final double finalKm = await showDialog<double>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _FinalizeJornadaDialog(
            suggestedKm: jornadaRastreada.kmPercorrido,
          ),
        ) ??
        0.0;

    if (finalKm > 0) {
      final Jornada jornadaParaSalvar = _jornadaService.recalculateJornada(
        jornadaBase: jornadaRastreada,
        kmFinal: finalKm,
        profile: userProfile,
      );

      await _jornadaService.saveJornada(jornadaParaSalvar, userProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Jornada Salva! Custos Lançados no Relatório."),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      _controller.reset();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _controller.routePoints,
        color: Colors.blue,
        width: 5,
      ),
    };

    final LatLng initialCameraPosition = _controller.routePoints.isNotEmpty
        ? _controller.routePoints.last
        : const LatLng(-23.5505, -46.6333);

    return Scaffold(
      appBar: const Header(text: "Rastreamento"),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 15,
              ),
              mapType: MapType.normal,
              myLocationEnabled: _isTracking,
              myLocationButtonEnabled: true,
              polylines: polylines,
            ),
          ),

          // Painel de Controle e Dados em Tempo Real
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // --- TIMER (TEMPO DE EXECUÇÃO) ---
                Text(
                  _formatTime(_currentSeconds),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),

                // KM Atual Rodado
                const Text("KM Percorrido Nesta Jornada",
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
                Text(
                  _currentKm.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27214D)),
                ),

                const SizedBox(height: 10),

                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão INICIAR / CONTINUAR
                    if (!_isTracking || _isPaused)
                      _buildActionButton(
                        label:
                            _isTracking ? "Continuar" : "Iniciar Rastreamento",
                        icon: Icons.play_arrow,
                        color: Colors.green,
                        onPressed: _isTracking ? _resumeJornada : _startJornada,
                      ),

                    // Botão PAUSAR
                    if (_isTracking && !_isPaused)
                      _buildActionButton(
                        label: "Pausar",
                        icon: Icons.pause,
                        color: Colors.blueGrey,
                        onPressed: _pauseJornada,
                      ),

                    // Botão FINALIZAR
                    if (_isTracking)
                      _buildActionButton(
                        label: "Finalizar Jornada",
                        icon: Icons.stop,
                        color: Colors.red,
                        onPressed: _finishJornada,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Finalize dialog with template support
// ---------------------------------------------------------------------------

class _FinalizeJornadaDialog extends StatefulWidget {
  final double suggestedKm;

  const _FinalizeJornadaDialog({required this.suggestedKm});

  @override
  State<_FinalizeJornadaDialog> createState() =>
      _FinalizeJornadaDialogState();
}

class _FinalizeJornadaDialogState extends State<_FinalizeJornadaDialog> {
  late final TextEditingController _kmController;
  final _templateService = TemplateService();

  static const _kAccent = Color.fromARGB(255, 248, 151, 33);

  @override
  void initState() {
    super.initState();
    _kmController = TextEditingController(
        text: widget.suggestedKm.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _kmController.dispose();
    super.dispose();
  }

  void _applyTemplate(Template? template) {
    if (template == null) {
      _kmController.text = widget.suggestedKm.toStringAsFixed(2);
      return;
    }

    final p = template.payload;
    if (p['kmOverride'] != null) {
      _kmController.text = (p['kmOverride'] as double).toStringAsFixed(2);
    } else if (p['kmOffset'] != null) {
      final result = widget.suggestedKm + (p['kmOffset'] as double);
      _kmController.text = result.toStringAsFixed(2);
    }
    _templateService.incrementUsage(template.id);
  }

  Future<void> _saveAsTemplate() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const SaveTemplateDialog(suggestedName: 'Jornada padrão'),
    );
    if (name == null || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final kmValue = double.tryParse(_kmController.text);
    await _templateService.saveTemplate(Template(
      id: '',
      userId: user.uid,
      formType: FormType.jornadaFinal,
      name: name,
      createdAt: DateTime.now(),
      payload: {'kmOverride': kmValue},
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modelo salvo!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmar Jornada"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KM Percorrido detectado:"),
          Text("${widget.suggestedKm.toStringAsFixed(2)} km",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Modelos:',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              Expanded(
                child: TemplateChipRow(
                  formType: FormType.jornadaFinal,
                  templateService: _templateService,
                  onTemplateSelected: _applyTemplate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _kmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "KM Final (Edite se necessário)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 0.0),
          child: const Text("Cancelar"),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          color: _kAccent,
          tooltip: 'Salvar como modelo',
          onPressed: _saveAsTemplate,
        ),
        ElevatedButton(
          onPressed: () {
            final double? finalKm = double.tryParse(_kmController.text);
            Navigator.pop(context, finalKm ?? 0.0);
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: _kAccent),
          child: const Text("Salvar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
