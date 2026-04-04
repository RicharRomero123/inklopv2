import 'dart:convert';
import 'package:flutter/material.dart';

class UrlInputModal extends StatefulWidget {
  final String platform;
  final Future<void> Function(String) onConfirm;

  const UrlInputModal({
    super.key,
    required this.platform,
    required this.onConfirm,
  });

  @override
  State<UrlInputModal> createState() => _UrlInputModalState();
}

class _UrlInputModalState extends State<UrlInputModal> {
  final _controller = TextEditingController();
  String _previewUsername = ''; // La lógica se mantiene internamente
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_errorMessage != null) setState(() => _errorMessage = null);
      setState(() {
        // Se sigue procesando por dentro, pero ya no lo pintamos arriba
        _previewUsername = _extractUsername(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _extractUsername(String url) {
    if (url.trim().isEmpty) return '';
    try {
      final uri = Uri.parse(url.trim());
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return '@${segments.last}';
    } catch (_) {}
    final parts = url.trim().split('/').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return '@${parts.last}';
    return '';
  }

  Future<void> _handleConfirm() async {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un URL');
      return;
    }

    if (!url.toLowerCase().contains(widget.platform.toLowerCase())) {
      setState(() => _errorMessage = 'El URL no pertenece a ${widget.platform}');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(url);
    } catch (e) {
      setState(() {
        if (e.toString().contains('already exists')) {
          _errorMessage = 'Este perfil ya está vinculado a una cuenta';
        } else {
          _errorMessage = 'Error al vincular cuenta';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle superior (La barrita gris de arriba)
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Vincula tu cuenta de ${widget.platform}',
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Pega el URL de tu cuenta para verificarla.',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),

          // 🚀 CAMBIO: Solo mostramos el label "URL". Quitamos el Row y el Preview.
          Text(
            'URL',
            style: TextStyle(
              color: _errorMessage != null ? Colors.red : const Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Input Pill
          TextField(
            controller: _controller,
            enabled: !_isLoading,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'www.${widget.platform.toLowerCase()}.com/tuusuario',
              hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
              filled: true,
              fillColor: const Color(0xFFF2F2F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: _errorMessage != null
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: _errorMessage != null ? const BorderSide(color: Colors.red) : BorderSide.none,
              ),
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),

          const SizedBox(height: 24),

          // Botón Continuar Pill
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: _isLoading ? Colors.grey : Colors.black,
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Continuar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}