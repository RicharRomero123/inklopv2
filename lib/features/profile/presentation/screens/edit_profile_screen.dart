import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inklop_v1/core/utils/custom_input.dart';
import '../../data/profile_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> initialData;

  const EditProfileScreen({super.key, required this.accessToken, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileApiService _apiService = ProfileApiService();
  final _picker = ImagePicker();
  File? _newImage;
  bool _isSaving = false;

  late TextEditingController _userController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.initialData['username']);
    _descController = TextEditingController(text: widget.initialData['description']);
    _phoneController = TextEditingController(text: widget.initialData['phoneNumber']);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newImage = File(image.path));
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      // 1. Actualizar Datos de Texto
      await _apiService.updateProfile(widget.accessToken, {
        "username": _userController.text,
        "description": _descController.text,
        "phoneNumber": _phoneController.text,
      });

      // 2. Actualizar Imagen si se seleccionó una nueva
      if (_newImage != null) {
        await _apiService.updateProfileImage(widget.accessToken, _newImage!);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Editar Perfil', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _newImage != null
                        ? FileImage(_newImage!)
                        : (widget.initialData['avatarUrl'] != null ? NetworkImage(widget.initialData['avatarUrl']) : null) as ImageProvider?,
                  ),
                  const CircleAvatar(radius: 15, backgroundColor: Colors.black, child: Icon(Icons.camera_alt, size: 15, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomInput(label: 'Username', hint: '@usuario', controller: _userController, focusNode: FocusNode()),
            const SizedBox(height: 16),
            CustomInput(label: 'Teléfono', hint: '999999999', controller: _phoneController, focusNode: FocusNode(), isNumber: true),
            const SizedBox(height: 16),
            CustomInput(label: 'Biografía', hint: 'Cuéntanos algo...', controller: _descController, focusNode: FocusNode(), isBio: true),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar Cambios'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}