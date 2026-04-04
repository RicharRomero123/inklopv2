import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/profile_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> initialData;

  const EditProfileScreen({
    super.key,
    required this.accessToken,
    required this.initialData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileApiService _apiService = ProfileApiService();
  final _picker = ImagePicker();
  File? _newImage;
  bool _isSaving = false;

  // Username validation
  Timer? _debounce;
  bool _isValidatingUser = false;
  bool _isUserAvailable = true;

  // Controllers
  late TextEditingController _userController;
  late TextEditingController _namesController;
  late TextEditingController _lastNamesController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;

  // Focus nodes
  final _userFocus = FocusNode();
  final _namesFocus = FocusNode();
  final _lastNamesFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _descFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _userController = TextEditingController(text: d['username']);
    _namesController = TextEditingController(text: d['names']);
    _lastNamesController = TextEditingController(text: d['lastNames']);
    _countryController = TextEditingController(text: d['country']);
    _cityController = TextEditingController(text: d['city']);
    _phoneController = TextEditingController(text: d['phoneNumber']);
    _descController = TextEditingController(text: d['description']);

    // Rebuild on focus change so borders update
    for (final fn in [
      _userFocus, _namesFocus, _lastNamesFocus,
      _countryFocus, _cityFocus, _phoneFocus, _descFocus,
    ]) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _userController, _namesController, _lastNamesController,
      _countryController, _cityController, _phoneController, _descController,
    ]) {
      c.dispose();
    }
    for (final fn in [
      _userFocus, _namesFocus, _lastNamesFocus,
      _countryFocus, _cityFocus, _phoneFocus, _descFocus,
    ]) {
      fn.dispose();
    }
    super.dispose();
  }

  // ── USERNAME VALIDATION ──────────────────────────────────────────────────
  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value == widget.initialData['username']) {
      setState(() => _isUserAvailable = true);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) return;
      setState(() => _isValidatingUser = true);
      final result = await _apiService.checkUsername(widget.accessToken, value);
      setState(() {
        _isUserAvailable = result != null && result['exists'] == false;
        _isValidatingUser = false;
      });
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newImage = File(image.path));
  }

  // ── SAVE ────────────────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (!_isUserAvailable) return;
    setState(() => _isSaving = true);

    final data = {
      "username": _userController.text,
      "names": _namesController.text,
      "lastnames": _lastNamesController.text,
      "country": _countryController.text,
      "city": _cityController.text,
      "phoneNumber": _phoneController.text,
      "description": _descController.text,
    };

    try {
      final success = await _apiService.updateProfile(widget.accessToken, data);
      if (_newImage != null) {
        await _apiService.updateProfileImage(widget.accessToken, _newImage!);
      }
      if (mounted && success) {
        _showSuccessToast();
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showErrorToast();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UBER-STYLE SUCCESS TOAST ─────────────────────────────────────────────
  void _showSuccessToast() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _UberToast(
        message: 'Perfil actualizado correctamente',
        icon: Icons.check_circle_rounded,
        isDark: true,
        accentColor: const Color(0xFF06C167),
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _showErrorToast() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _UberToast(
        message: 'Error al guardar los cambios',
        icon: Icons.error_rounded,
        isDark: false,
        accentColor: const Color(0xFFE63946),
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Avatar
                  _buildAvatarSection(),
                  const SizedBox(height: 32),

                  // Username
                  _buildLabel('Nombre de usuario'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _userController,
                    focusNode: _userFocus,
                    hint: '@usuario',
                    onChanged: _onUsernameChanged,
                    suffix: _isValidatingUser
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                        : Icon(
                      _isUserAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _isUserAvailable ? const Color(0xFF06C167) : const Color(0xFFE63946),
                      size: 20,
                    ),
                  ),
                  if (!_isUserAvailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Este nombre de usuario ya existe',
                        style: TextStyle(color: Color(0xFFE63946), fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Nombre / Apellido
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Nombre'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _namesController,
                              focusNode: _namesFocus,
                              hint: 'Ej. Juan',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Apellido'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _lastNamesController,
                              focusNode: _lastNamesFocus,
                              hint: 'Ej. Pérez',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  _buildLabel('Bio'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    focusNode: _descFocus,
                    hint: 'Cuéntanos algo sobre ti...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),

                  // País / Ciudad
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('País'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _countryController,
                              focusNode: _countryFocus,
                              hint: 'Perú',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Ciudad'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _cityController,
                              focusNode: _cityFocus,
                              hint: 'Lima',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Teléfono
                  _buildLabel('Teléfono'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    hint: '999 999 999',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ── AVATAR ───────────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: const Color(0xFFF2F2F7),
                    image: _newImage != null
                        ? DecorationImage(image: FileImage(_newImage!), fit: BoxFit.cover)
                        : (widget.initialData['avatarUrl'] != null
                        ? DecorationImage(
                      image: NetworkImage(widget.initialData['avatarUrl']),
                      fit: BoxFit.cover,
                    )
                        : null),
                  ),
                  child: widget.initialData['avatarUrl'] == null && _newImage == null
                      ? const Icon(Icons.person_rounded, size: 36, color: Colors.grey)
                      : null,
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.initialData['names'] ?? '',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BUTTONS ───────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Color(0xFFD1D1D6), width: 1.5),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: (_isSaving || !_isUserAvailable) ? null : _saveChanges,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.black.withOpacity(0.3),
                  shape: const StadiumBorder(),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      color: Color(0xFF8E8E93),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Widget? suffix,
  }) {
    final isFocused = focusNode.hasFocus;
    // Single-line fields use pill shape; multiline use large rounded rect
    final radius = maxLines > 1 ? 20.0 : 50.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isFocused ? Colors.black : Colors.transparent,
          width: 1.8,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.28),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 16), child: suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 16 : 16,
          ),
        ),
      ),
    );
  }
}

// ── UBER-STYLE TOAST ────────────────────────────────────────────────────────
class _UberToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final bool isDark; // true = dark bg (success), false = white bg (error)
  final Color accentColor;
  final VoidCallback onDismiss;

  const _UberToast({
    required this.message,
    required this.icon,
    required this.isDark,
    required this.accentColor,
    required this.onDismiss,
  });

  @override
  State<_UberToast> createState() => _UberToastState();
}

class _UberToastState extends State<_UberToast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _slide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final iconBg = widget.isDark
        ? Colors.white.withOpacity(0.12)
        : widget.accentColor.withOpacity(0.1);
    final iconColor = widget.isDark ? Colors.white : widget.accentColor;

    return Positioned(
      bottom: 110,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slide.value),
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.35 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(widget.icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                // Message
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                // Close
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.5)
                        : const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}