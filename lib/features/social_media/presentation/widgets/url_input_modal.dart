import 'package:flutter/material.dart';

class UrlInputModal extends StatefulWidget {
  final String platform;
  final Function(String) onConfirm;

  const UrlInputModal({super.key, required this.platform, required this.onConfirm});

  @override
  State<UrlInputModal> createState() => _UrlInputModalState();
}

class _UrlInputModalState extends State<UrlInputModal> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 32
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Vincula tu cuenta de ${widget.platform}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Pega aquí el URL de tu perfil para verificarla y generar un código.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'www.${widget.platform.toLowerCase()}.com/tuusuario',
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => widget.onConfirm(_controller.text),
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}