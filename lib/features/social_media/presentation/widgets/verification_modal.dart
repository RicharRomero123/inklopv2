import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inklop_v1/features/social_media/data/models/social_media_model.dart';

class VerificationModal extends StatefulWidget {
  final SocialMediaAccount account;
  final Future<bool> Function() onVerify;

  const VerificationModal({super.key, required this.account, required this.onVerify});

  @override
  State<VerificationModal> createState() => _VerificationModalState();
}

class _VerificationModalState extends State<VerificationModal> {
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Verificación pendiente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Para completar la verificación debes colocar el código en tu biografía o descripción de perfil.',
              textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // Card de la cuenta
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Row(
              children: [
                Icon(widget.account.platform == 'TIKTOK' ? Icons.music_note : Icons.camera_alt),
                const SizedBox(width: 12),
                Text(widget.account.displayUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Código de verificación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.account.verificationCode,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.account.verificationCode));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado')));
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity, height: 56,
            child: FilledButton(
              onPressed: _isVerifying ? null : () async {
                setState(() => _isVerifying = true);
                final success = await widget.onVerify();
                if (!success && mounted) setState(() => _isVerifying = false);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verificar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}