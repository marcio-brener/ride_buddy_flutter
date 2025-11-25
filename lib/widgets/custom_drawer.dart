import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_buddy_flutter/services/user_service.dart';
import 'package:ride_buddy_flutter/models/user_profile.dart';
import 'package:ride_buddy_flutter/screens/profile_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final UserService _userService = UserService();
  UserProfile? _userProfile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
      try {
        final profile = await _userService.getUserProfile();
        if (mounted) {
          setState(() {
            _userProfile = profile;
          });
        }
      } catch (e) {
        print("Erro ao carregar perfil no drawer: $e");
      }
    }

    Future<void> _saveImage(String? base64Image) async {
    if (_userProfile != null) {
  
      final novoPerfil = _userProfile!.copyWith(
        fotoUrl: () => base64Image, 
      );

      await _userService.saveUserProfile(novoPerfil);
      await _loadUser();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final String base64Image = base64Encode(bytes);
        await _saveImage(base64Image);
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  void _showImageOptions() {
    final hasImage = _userProfile?.fotoUrl != null && _userProfile!.fotoUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (hasImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _saveImage(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    final userName = _userProfile?.nome.isNotEmpty == true 
        ? _userProfile!.nome 
        : "Motorista";
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : "M";

    final hasImage =
        _userProfile?.fotoUrl != null && _userProfile!.fotoUrl!.isNotEmpty;
    ImageProvider? imageProvider;
    if (hasImage) {
      try {
        imageProvider = MemoryImage(base64Decode(_userProfile!.fotoUrl!));
      } catch (e) {
        print("Erro ao decodificar imagem: $e");
      }
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 248, 151, 33),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: imageProvider,
                        child: !hasImage
                            ? Text(
                                userInitial,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 248, 151, 33),
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _showImageOptions,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black54),
            title: const Text("Editar Perfil e Veículo"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _loadUser());
            },
          ),
          const Spacer(),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sair", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut(); 
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}