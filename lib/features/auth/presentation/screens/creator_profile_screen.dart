import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inklop_v1/core/utils/custom_input.dart';
import 'package:inklop_v1/features/social_media/presentation/screens/social_media_link_screen.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/user_api_service.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String accessToken;
  final String birthDate;
  final String email;

  const CreatorProfileScreen({super.key, required this.accessToken, required this.birthDate, required this.email});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  final UserApiService _apiService = UserApiService();
  final SecureStorageService _storageService = SecureStorageService();

  // Validador de Username
  Timer? _debounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameValid;

  // Estados
  bool _isLoadingPost = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final _controllers = {
    'username': TextEditingController(),
    'names': TextEditingController(),
    'lastNames': TextEditingController(),
    'document': TextEditingController(),
    'phone': TextEditingController(),
    'bio': TextEditingController(),
  };

  @override
  void dispose() {
    _debounce?.cancel();
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  // --- LÓGICA TIPO INSTAGRAM ---
  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.isEmpty) { setState(() => _isUsernameValid = null); return; }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameValid = null;
    });

    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final res = await _apiService.checkUsername(value, widget.accessToken);
      if (mounted) {
        setState(() {
          // Disponible si valid: true y exists: false
          _isUsernameValid = (res['valid'] == true && res['exists'] == false);
          _isCheckingUsername = false;
        });
      }
    });
  }

  // --- SUBIDA Y REGISTRO ---
  Future<void> _submitData() async {
    if (_isUsernameValid != true) { _showSnackBar('Nombre de usuario no disponible', Colors.red); return; }
    if (_profileImage == null) { _showSnackBar('La foto es obligatoria', Colors.orange); return; }

    setState(() => _isLoadingPost = true);

    try {
      // 1. Obtener Firma y Estructura (NUEVO)
      final responseData = await _apiService.getCloudinarySignature(widget.accessToken);
      if (responseData == null) throw Exception("Error al obtener datos de subida del backend");

      // 2. Subir a Cloudinary (Usa la URL y el body del JSON)
      final imageUrl = await _apiService.uploadToCloudinary(_profileImage!, responseData);
      if (imageUrl == null) throw Exception("Fallo al subir imagen a Cloudinary");

      // 3. Payload Final
      final payload = {
        "names": _controllers['names']!.text.trim(),
        "lastNames": _controllers['lastNames']!.text.trim(),
        "username": _controllers['username']!.text.trim(),
        "typeDocument": "DNI",
        "document": _controllers['document']!.text.trim(),
        "country": "Perú",
        "city": "Lima",
        "phoneNumber": _controllers['phone']!.text.trim(),
        "birthDate": widget.birthDate,
        "description": _controllers['bio']!.text.trim(),
        "imageUrl": imageUrl
      };

      // 4. Registro en Inklop
      final success = await _apiService.registerCreatorProfile(payload: payload, token: widget.accessToken);

      if (success && mounted) {
        await _storageService.saveToken(widget.accessToken);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SocialMediaLinkScreen(accessToken: widget.accessToken)),
                (r) => false
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingPost = false);
    }
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    Widget? userIcon = _isCheckingUsername
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
        : (_isUsernameValid == true ? const Icon(Icons.check_circle, color: Colors.green) : (_isUsernameValid == false ? const Icon(Icons.cancel, color: Colors.red) : null));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                if (img != null) setState(() => _profileImage = File(img.path));
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.camera_alt, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(height: 32),
            CustomInput(label: 'Username', hint: '@user', controller: _controllers['username']!, focusNode: FocusNode(), onChanged: _onUsernameChanged, suffixIcon: Padding(padding: const EdgeInsets.all(12), child: userIcon)),
            if (_isUsernameValid == false) const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 12), child: Text('No disponible o inválido', style: TextStyle(color: Colors.red, fontSize: 12)))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: CustomInput(label: 'Nombre', hint: 'Nombres', controller: _controllers['names']!, focusNode: FocusNode())),
              const SizedBox(width: 12),
              Expanded(child: CustomInput(label: 'Apellido', hint: 'Apellidos', controller: _controllers['lastNames']!, focusNode: FocusNode())),
            ]),
            const SizedBox(height: 16),
            CustomInput(label: 'Teléfono móvil', hint: '999999999', controller: _controllers['phone']!, focusNode: FocusNode(), isNumber: true),
            const SizedBox(height: 16),
            CustomInput(label: 'DNI', hint: 'Número', controller: _controllers['document']!, focusNode: FocusNode(), isNumber: true),
            const SizedBox(height: 16),
            CustomInput(label: 'Bio', hint: 'Sobre ti...', controller: _controllers['bio']!, focusNode: FocusNode(), isBio: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: FilledButton(
                onPressed: (_isLoadingPost || _isUsernameValid != true) ? null : _submitData,
                style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                child: _isLoadingPost ? const CircularProgressIndicator(color: Colors.white) : const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}