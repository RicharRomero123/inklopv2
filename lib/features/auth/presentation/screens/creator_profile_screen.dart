import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inklop_v1/features/social_media/presentation/screens/social_media_link_screen.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/user_api_service.dart';
import '../../data/auth_service.dart'; // 🚀 Importamos el AuthService

class CreatorProfileScreen extends StatefulWidget {
  final String accessToken;
  final String birthDate;
  final String email;

  const CreatorProfileScreen({
    super.key,
    required this.accessToken,
    required this.birthDate,
    required this.email,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  final UserApiService _apiService = UserApiService();
  final SecureStorageService _storageService = SecureStorageService();
  final AuthService _authService = AuthService(); // 🚀 Instancia de AuthService

  Timer? _debounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameValid;

  bool _isLoadingPost = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, TextEditingController> _controllers = {
    'username': TextEditingController(),
    'names': TextEditingController(),
    'lastNames': TextEditingController(),
    'document': TextEditingController(),
    'phone': TextEditingController(),
    'bio': TextEditingController(),
  };

  final Map<String, FocusNode> _focusNodes = {
    'username': FocusNode(),
    'names': FocusNode(),
    'lastNames': FocusNode(),
    'document': FocusNode(),
    'phone': FocusNode(),
    'bio': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    _focusNodes.forEach((_, node) => node.addListener(() => setState(() {})));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controllers.forEach((_, c) => c.dispose());
    _focusNodes.forEach((_, n) => n.dispose());
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.isEmpty) {
      setState(() => _isUsernameValid = null);
      return;
    }
    setState(() {
      _isCheckingPassword();
      _isCheckingUsername = true;
      _isUsernameValid = null;
    });
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final res = await _apiService.checkUsername(value, widget.accessToken);
      if (mounted) {
        setState(() {
          _isUsernameValid = (res['valid'] == true && res['exists'] == false);
          _isCheckingUsername = false;
        });
      }
    });
  }

  void _isCheckingPassword() {}

  // ── SUBMIT CON REFRESH TOKEN FORZADO ──────────────────────────────────────
  Future<void> _submitData() async {
    if (_isUsernameValid != true) {
      _showSnackBar('Nombre de usuario no disponible', Colors.red);
      return;
    }
    if (_profileImage == null) {
      _showSnackBar('La foto es obligatoria', Colors.orange);
      return;
    }

    setState(() => _isLoadingPost = true);

    try {
      // 1. Obtener firma y subir a Cloudinary
      final responseData = await _apiService.getCloudinarySignature(widget.accessToken);
      if (responseData == null) throw Exception("Error en firma de Cloudinary");

      final imageUrl = await _apiService.uploadToCloudinary(_profileImage!, responseData);
      if (imageUrl == null) throw Exception("Fallo al subir imagen");

      // 2. Registrar perfil en el Backend
      final payload = {
        "names": _controllers['names']!.text.trim(),
        "lastNames": _controllers['lastNames']!.text.trim(),
        "username": _controllers['username']!.text.trim(),
        "documentType": "DNI",
        "document": _controllers['document']!.text.trim(),
        "country": "Perú",
        "city": "Lima",
        "phoneNumber": _controllers['phone']!.text.trim(),
        "birthDate": widget.birthDate,
        "description": _controllers['bio']!.text.trim(),
        "imageUrl": imageUrl,
      };

      final success = await _apiService.registerCreatorProfile(
          payload: payload, token: widget.accessToken);

      if (success && mounted) {
        // 🚀 3. PROCESO DE REFRESH TOKEN OBLIGATORIO
        // Necesitamos renovar el token para que los nuevos permisos de Creador se activen
        final String? storedRefreshToken = await _storageService.getRefreshToken();

        if (storedRefreshToken != null) {
          // Llamamos a la función que mapeaste en el AuthService
          final newTokens = await _authService.renewToken(storedRefreshToken);

          final String? newToken = newTokens['token'];
          final String? newRefresh = newTokens['refreshToken'];

          if (newToken != null) {
            // Guardamos los tokens frescos (Access y Refresh actualizado)
            await _storageService.saveToken(
              access: newToken,
              refresh: newRefresh ?? storedRefreshToken,
            );

            // 4. Navegamos con el token NUEVO y FRESCO
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => SocialMediaLinkScreen(accessToken: newToken),
                ),
                    (r) => false,
              );
            }
          }
        } else {
          // Fallback en caso de no haber refresh token (poco probable)
          await _storageService.saveAccessToken(widget.accessToken);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => SocialMediaLinkScreen(accessToken: widget.accessToken),
              ),
                  (r) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingPost = false);
    }
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (img != null) setState(() => _profileImage = File(img.path));
  }

  @override
  Widget build(BuildContext context) {
    Widget? usernameIcon = _isCheckingUsername
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
        : _isUsernameValid == true
        ? const Icon(Icons.check_circle, color: Colors.green)
        : _isUsernameValid == false
        ? const Icon(Icons.cancel, color: Colors.red)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Foto de Perfil
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        height: 110, width: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          shape: BoxShape.circle,
                          image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
                        ),
                        child: _profileImage == null ? const Icon(Icons.person, size: 55, color: Colors.black) : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          height: 36, width: 36,
                          decoration: BoxDecoration(color: const Color(0xFFE0E0E0), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                          child: const Icon(Icons.edit, size: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Completa Tu Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildInput(label: 'Nombre de usuario', hint: '@username', keyName: 'username', onChanged: _onUsernameChanged, suffix: usernameIcon != null ? Padding(padding: const EdgeInsets.all(12), child: usernameIcon) : null),
              if (_isUsernameValid == false) const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 12, top: 4), child: Text('No disponible o inválido', style: TextStyle(color: Colors.red, fontSize: 12)))),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Nombre', hint: 'Nombres', keyName: 'names')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Apellido', hint: 'Apellidos', keyName: 'lastNames')),
                ],
              ),
              const SizedBox(height: 12),
              _buildInput(label: 'Bio', hint: 'Sobre ti...', keyName: 'bio', isBio: true),
              const SizedBox(height: 12),
              _buildInput(label: 'Teléfono', hint: '999999999', keyName: 'phone', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(label: 'DNI', hint: 'Documento', keyName: 'document', isNumber: true),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: (_isLoadingPost || _isUsernameValid != true) ? null : _submitData,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), shape: const StadiumBorder()),
                  child: _isLoadingPost
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required String hint, required String keyName, bool isBio = false, bool isNumber = false, Function(String)? onChanged, Widget? suffix}) {
    final focusNode = _focusNodes[keyName]!;
    final controller = _controllers[keyName]!;
    final bool isActive = focusNode.hasFocus || controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFADADAD), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(isBio ? 15 : 30),
            border: Border.all(color: isActive ? const Color(0xFFE0E0E0) : const Color(0xFFF3F3F3), width: 1.5),
          ),
          child: TextField(
            controller: controller, focusNode: focusNode,
            maxLines: isBio ? 3 : 1,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            onChanged: (val) { setState(() {}); onChanged?.call(val); },
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), suffixIcon: suffix),
          ),
        ),
      ],
    );
  }
}