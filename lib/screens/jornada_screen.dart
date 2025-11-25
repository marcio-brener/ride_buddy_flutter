import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_buddy_flutter/services/jornada_service.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/widgets/header.dart'; 

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

  final TextEditingController _kmController = TextEditingController();

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
    _kmController.dispose();
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
    final jornada = await _jornadaService.stopTracking(); 
    final userProfile = await _userService.getUserProfile(); 
    
    final double finalKm = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFinalizeDialog(jornada.kmPercorrido),
    ) ?? 0.0;
    
    if (finalKm > 0) {
    final jornadaParaSalvar = jornada.copyWith(
      kmPercorrido: finalKm,
      duracaoSegundos: _controller.seconds, 
    );
      
      await _jornadaService.saveJornada(jornadaParaSalvar, userProfile); 
      
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Jornada Salva! Custos Lançados no Relatório."), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } else {
      _controller.reset();
      if (mounted) Navigator.pop(context);
    }
  }
  
  Widget _buildFinalizeDialog(double suggestedKm) {
    _kmController.text = suggestedKm.toStringAsFixed(2);
    
    return AlertDialog(
      title: const Text("Confirmar Jornada"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KM Percorrido detectado:"),
          Text("${suggestedKm.toStringAsFixed(2)} km", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: _kmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "KM Final (Edite se necessário)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 0.0), 
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final double? finalKm = double.tryParse(_kmController.text);
            Navigator.pop(context, finalKm ?? 0.0);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 248, 151, 33)),
          child: const Text("Salvar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
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
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),

                // KM Atual Rodado
                const Text("KM Percorrido Nesta Jornada", style: TextStyle(fontSize: 18, color: Colors.black54)),
                Text(
                  _currentKm.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF27214D)),
                ),
                
                const SizedBox(height: 10),
                
                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão INICIAR / CONTINUAR
                    if (!_isTracking || _isPaused)
                      _buildActionButton(
                        label: _isTracking ? "Continuar" : "Iniciar Rastreamento",
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
  
  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
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