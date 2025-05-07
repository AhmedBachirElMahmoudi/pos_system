import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Pour déterminer la plateforme
import 'dart:typed_data'; // Pour Uint8List

// Import conditionnel pour la fonctionnalité web
import 'package:frontend/components/web_image_picker.dart' if (dart.library.io) 'package:frontend/components/stub_web_image_picker.dart';

class EditUserInfoScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserInfoScreen({super.key, required this.user});

  @override
  _EditUserInfoScreenState createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  io.File? _imageFile;
  Uint8List? _webImageData;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['nom']);
    _emailController = TextEditingController(text: widget.user['email']);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Afficher l'indicateur de chargement et revenir à l'écran d'accueil
  Future<void> _showLoadingAndReturn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); // Fermer la boîte de dialogue
      Navigator.pop(context); // Retourner à l'écran précédent
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print('Nom: $name');
      print('Email: $email');
      print('Password: $password');
      print('Image Path: ${_imageFile?.path ?? _imageName ?? 'Aucune'}');

      await _showLoadingAndReturn();
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Gestion de la plateforme Web
      try {
        final webPicker = WebImagePicker();
        final imageData = await webPicker.pickImage();
        if (imageData != null) {
          setState(() {
            _webImageData = imageData;
            _imageName = 'web_image.jpg'; // Nom d'espace réservé
          });
        }
      } catch (e) {
        print('Erreur lors de la sélection de l\'image web: $e');
      }
    } else {
      // Plateformes mobiles et de bureau
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _imageFile = io.File(result.files.single.path!);
            _imageName = result.files.single.name;
          });
        }
      } catch (e) {
        print('Erreur lors de la sélection de l\'image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mes informations'),
        backgroundColor: Colors.blue, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showLoadingAndReturn,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center, 
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _getImageProvider(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'L\'email est requis' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: widget.user['role'],
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.shield),
                  border: OutlineInputBorder(),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveForm, 
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Méthode d'aide pour obtenir le fournisseur d'image approprié
  ImageProvider _getImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_webImageData != null) {
      return MemoryImage(_webImageData!);
    } else if (widget.user['image'] != null && widget.user['image']!.isNotEmpty) {
      return NetworkImage(widget.user['image']);
    } else {
      return const AssetImage('assets/default_image.png');
    }
  }
}