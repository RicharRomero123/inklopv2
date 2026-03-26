import 'dart:async';
import 'dart:convert';
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

  Timer? _debounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameValid;
  bool _isLoadingPost = false;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String _selectedDocType = 'DNI';
  String _selectedCountry = 'Perú';
  String _selectedCity = 'Lima';

  final List<String> _docTypes = ['DNI', 'RUC', 'CE', 'PASAPORTE'];
  final List<String> _peruCities = [
    'Lima', 'Arequipa', 'Trujillo', 'Chiclayo', 'Iquitos', 'Piura', 'Cusco', 'Huancayo'
  ];

  final _controllers = {
    'username': TextEditingController(),
    'nombre': TextEditingController(),
    'apellido': TextEditingController(),
    'documento': TextEditingController(),
    'telefono': TextEditingController(),
    'bio': TextEditingController(),
  };

  final _focusNodes = {
    'username': FocusNode(),
    'nombre': FocusNode(),
    'apellido': FocusNode(),
    'documento': FocusNode(),
    'telefono': FocusNode(),
    'bio': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    _focusNodes.forEach((k, v) => v.addListener(() => setState(() {})));
  }

  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.isEmpty) {
      setState(() { _isUsernameValid = null; _isCheckingUsername = false; });
      return;
    }

    setState(() => _isCheckingUsername = true);
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final result = await _apiService.checkUsername(value, widget.accessToken);
      if (mounted) {
        setState(() {
          _isUsernameValid = (result['valid'] == true && result['exists'] == false);
          _isCheckingUsername = false;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) setState(() => _profileImage = File(image.path));
    } catch (e) {
      debugPrint("Error seleccionando imagen: $e");
    }
  }

  Future<void> _submitData() async {
    if (_isUsernameValid != true) return;

    if (_profileImage == null) {
      _showSnackBar('Por favor, selecciona una foto de perfil.', Colors.orange);
      return;
    }

    if (_controllers.values.any((c) => c.text.trim().isEmpty)) {
      _showSnackBar('Por favor, completa todos los campos.', Colors.orange);
      return;
    }

    setState(() => _isLoadingPost = true);

    try {
      final payload = {
        "real_name": '${_controllers['nombre']!.text} ${_controllers['apellido']!.text}'.trim(),
        "username": _controllers['username']!.text.trim(),
        "email": widget.email,
        "typeDocument": _selectedDocType,
        "document": _controllers['documento']!.text.trim(),
        "country": _selectedCountry,
        "city": _selectedCity,
        "phoneNumber": _controllers['telefono']!.text.trim(),
        "birthDate": widget.birthDate,
        "description": _controllers['bio']!.text.trim()
      };

      final success = await _apiService.registerCreatorProfile(
        payload: payload,
        token: widget.accessToken,
        imageFile: _profileImage,
      );

      if (success) {
        await _storageService.saveToken(widget.accessToken);
        if (mounted) {
          // 🚀 2. CAMBIO AQUÍ: Ahora navegamos a SocialMediaLinkScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => SocialMediaLinkScreen(accessToken: widget.accessToken),
            ),
                (route) => false,
          );
        }
      } else {
        throw Exception('Error 400: El servidor rechazó los datos. Revisa el log.');
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoadingPost = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? usernameStatusIcon = _isCheckingUsername
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : (_isUsernameValid == true
        ? const Icon(Icons.check_circle, color: Colors.green)
        : (_isUsernameValid == false ? const Icon(Icons.cancel, color: Colors.red) : null));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFF3F3F3),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Icon(Icons.edit, size: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Text('Completa Tu Perfil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const Center(child: Text('Date a conocer en la comunidad Inklop', style: TextStyle(fontSize: 14, color: Colors.grey))),
              const SizedBox(height: 32),

              CustomInput(
                label: 'Nombre de usuario',
                hint: '@username',
                controller: _controllers['username']!,
                focusNode: _focusNodes['username']!,
                onChanged: _onUsernameChanged,
                suffixIcon: Padding(padding: const EdgeInsets.all(12), child: usernameStatusIcon),
              ),
              if (_isUsernameValid == false)
                const Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Text('Usuario no disponible', style: TextStyle(color: Colors.red, fontSize: 12))),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: CustomInput(label: 'Nombre', hint: 'Tu nombre', controller: _controllers['nombre']!, focusNode: _focusNodes['nombre']!)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomInput(label: 'Apellido', hint: 'Tu apellido', controller: _controllers['apellido']!, focusNode: _focusNodes['apellido']!)),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildLabelDropdown('País', _selectedCountry, ['Perú'], (val) => setState(() => _selectedCountry = val!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLabelDropdown('Ciudad', _selectedCity, _peruCities, (val) => setState(() => _selectedCity = val!))),
                ],
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Teléfono móvil',
                hint: '999999999',
                controller: _controllers['telefono']!,
                focusNode: _focusNodes['telefono']!,
                isNumber: true,
              ),
              const SizedBox(height: 16),

              const Text('Documento de identidad', style: TextStyle(color: Color(0xFFADADAD), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildDropdown(_selectedDocType, _docTypes, (val) => setState(() => _selectedDocType = val!)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFF3F3F3), width: 1.5)
                      ),
                      child: TextField(
                        controller: _controllers['documento'],
                        focusNode: _focusNodes['documento'],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                            hintText: 'Número',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomInput(
                  label: 'Biografía',
                  hint: 'Cuéntanos un poco sobre ti...',
                  controller: _controllers['bio']!,
                  focusNode: _focusNodes['bio']!,
                  isBio: true
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: (_isLoadingPost || _isUsernameValid != true) ? null : _submitData,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: const StadiumBorder(),
                  ),
                  child: _isLoadingPost
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFADADAD), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildDropdown(value, items, onChanged),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFF3F3F3), width: 1.5)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}