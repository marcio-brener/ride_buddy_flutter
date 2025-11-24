import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ride_buddy_flutter/models/jornada.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';

// Identificadores de Serviço e Notificação
const String notificationChannelId = 'ridetracking_foreground';

// --- CLASSE DE CONTROLE DE ESTADO (Singleton para comunicação) ---
class JornadaController {
  static final JornadaController _instance = JornadaController._internal();
  factory JornadaController() => _instance;
  JornadaController._internal();

  bool isRunning = false;
  bool isPaused = false;
  int seconds = 0;
  List<LatLng> routePoints = [];
  double distanceKm = 0.0;

  final StreamController<Map<String, dynamic>> _dataController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  void updateDistance(double newDistance, LatLng newPoint) {
    distanceKm = newDistance;
    routePoints.add(newPoint);

    _dataController.add({
      'km': distanceKm,
      'time': seconds,
      'isRunning': isRunning,
      'isPaused': isPaused,
    });
  }

  void updateData(
      {double? distance,
      List<LatLng>? points,
      int? time,
      bool? isRunning,
      bool? isPaused}) {
    if (distance != null) distanceKm = distance;
    if (points != null) routePoints = points;
    if (time != null) seconds = time;
    if (isRunning != null) this.isRunning = isRunning;
    if (isPaused != null) this.isPaused = isPaused;

    _dataController.add({
      'km': distanceKm,
      'time': seconds,
      'isRunning': this.isRunning,
      'isPaused': this.isPaused,
    });
  }

  void reset() {
    isRunning = false;
    isPaused = false;
    seconds = 0;
    routePoints = [];
    distanceKm = 0.0;
    _dataController.add({
      'km': 0.0,
      'time': 0,
      'isRunning': false,
      'isPaused': false,
    });
  }
}

// --- CLASSE PRINCIPAL DO SERVIÇO ---

class JornadaService {
  final UserService _userService = UserService();
  final JornadaController _controller = JornadaController();

  String? get _currentUserId => _userService.currentUserId;

  // 1. Inicializa o serviço de background no MAIN.DART
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Rastreamento de Jornada',
      description: 'Canal para serviço de rastreamento em segundo plano.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStartService,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: notificationChannelId,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStartService,
        onBackground: onIosBackground,
        autoStart: false,
      ),
    );
  }

  // --- MÉTODOS DE CONTROLE DA JORNADA (FRONT-END) ---
  // ... (startTracking, pauseTracking, resumeTracking, stopTracking, saveJornada, getJornadas, deleteJornada mantidos) ...

  Future<void> startTracking() async {
    // 1. Checagem de Permissões
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          "O serviço de localização (GPS) está desativado no seu dispositivo.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception(
          "Acesso à localização negado. O rastreamento não pode ser iniciado.");
    }

    // 2. Inicia o Serviço Nativo
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      await service.startService();
    }

    // 3. Reseta o estado local e atualiza o controller
    _controller.reset();
    _controller.isRunning = true;
    _controller.updateData(isRunning: true, isPaused: false);

    // Avisa o Background Service para começar a escuta
    service.invoke("startGpsListener");
  }

  void pauseTracking() {
    _controller.updateData(isPaused: true);
    FlutterBackgroundService().invoke("setAsPaused");
  }

  void resumeTracking() {
    _controller.updateData(isPaused: false);
    FlutterBackgroundService().invoke("setAsRunning");
  }

  Future<Jornada> stopTracking() async {
    _controller.isRunning = false;

    final profile = await _userService.getUserProfile();
    final double distanciaPercorrida = _controller.distanceKm;

    final double precoGasolina = profile.precoGasolinaAtual;
    final double kmPorLitro = profile.kmPorLitro;

    final double gastoTotalGasolina = (kmPorLitro > 0 && precoGasolina > 0)
        ? (distanciaPercorrida / kmPorLitro) * precoGasolina
        : 0.0;

    final double desgaste = distanciaPercorrida;

    return Jornada(
      id: '',
      dataFim: DateTime.now(),
      kmPercorrido: distanciaPercorrida,
      gastoGasolina: gastoTotalGasolina,
      desgasteOleoKm: desgaste,
      desgastePneuKm: desgaste,
    );
  }

  Future<void> saveJornada(Jornada jornada, UserProfile profile) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('jornadas')
        .add(jornada.toMap());

    final novoKmAtual = profile.kmAtual + jornada.kmPercorrido.toInt();

    final profileComKmAtualizado = profile.copyWith(
      kmAtual: novoKmAtual,
    );

    await _userService.saveUserProfile(profileComKmAtualizado);

    FlutterBackgroundService().invoke("stopService");
    _controller.reset();
  }

  Stream<List<Jornada>> getJornadas() {
    final userId = _currentUserId;
    if (userId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('jornadas')
        .orderBy('dataFim', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Jornada.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteJornada(String jornadaId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('jornadas')
        .doc(jornadaId)
        .delete();
  }

  // --- MÉTODOS ESTÁTICOS PARA O BACKGROUND SERVICE (ISOLATE) ---

  static String _formatTime(int totalSeconds) {
    final int seconds = totalSeconds % 60;
    final int minutes = (totalSeconds ~/ 60) % 60;
    final int hours = (totalSeconds ~/ 3600);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Função que roda em um isolate separado (segundo plano)
  @pragma('vm:entry-point')
  static Future<void> onStartService(ServiceInstance service) async {
    await Firebase.initializeApp();

    final serviceController = JornadaController();

    final androidService = service is AndroidServiceInstance ? service : null;

    // GARANTIR QUE O RASTREAMENTO COMEÇA COMO ATIVO
    serviceController.isRunning = true;
    serviceController.updateData(isRunning: true, isPaused: false);

    // 1. Listener para comandos da UI (pause/resume/stop)
    service
        .on("setAsPaused")
        .listen((event) => serviceController.updateData(isPaused: true));
    service
        .on("setAsRunning")
        .listen((event) => serviceController.updateData(isPaused: false));
    service.on("stopService").listen((event) {
      serviceController.isRunning = false;
      service.stopSelf();
    });

    // 2. Lógica do Timer e Notificação Persistente
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!serviceController.isPaused && serviceController.isRunning) {
        final int newTime = serviceController.seconds + 1;
        serviceController.updateData(
            time: newTime, isRunning: true, isPaused: false);
      }

      final String timeString = _formatTime(serviceController.seconds);

      // Atualiza a notificação
      if (androidService != null) {
        androidService.setForegroundNotificationInfo(
          title: "Ride Buddy: Rastreamento Ativo",
          content:
              "Tempo: $timeString | KM: ${serviceController.distanceKm.toStringAsFixed(2)} km",
        );
      }

      if (!serviceController.isRunning) {
        timer.cancel();
      }
    });

    // 3. Lógica de Rastreamento (Geolocator)
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (!serviceController.isRunning || serviceController.isPaused) return;

      final newPoint = LatLng(position.latitude, position.longitude);

      if (serviceController.routePoints.isNotEmpty) {
        final lastPoint = serviceController.routePoints.last;
        final distance = Geolocator.distanceBetween(
          lastPoint.latitude,
          lastPoint.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        serviceController.updateDistance(
          serviceController.distanceKm +
              (distance / 1000), // Converte metros para KM
          newPoint,
        );
      } else {
        serviceController.updateDistance(0.0, newPoint);
      }
    });
  }

  static bool onIosBackground(ServiceInstance service) {
    return true;
  }
}
