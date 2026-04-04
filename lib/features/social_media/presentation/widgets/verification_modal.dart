import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inklop_v1/features/social_media/data/models/social_media_model.dart';

class VerificationModal extends StatefulWidget {
  final SocialMediaAccount account;
  final Future<bool> Function() onVerify;
  final VoidCallback? onLater;

  const VerificationModal({
    super.key,
    required this.account,
    required this.onVerify,
    this.onLater,
  });

  @override
  State<VerificationModal> createState() => _VerificationModalState();
}

class _VerificationModalState extends State<VerificationModal> {
  bool _isVerifying = false;
  bool _hasError = false;

  String _getPlatformIcon(String platform) {
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        return 'assets/images/ic_tiktok.png';
      case 'INSTAGRAM':
        return 'assets/images/ic_instagram.png';
      default:
        return 'assets/images/ic_profile.png';
    }
  }

  void _showToast({required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success
                    ? '¡Cuenta verificada correctamente!'
                    : 'No se pudo verificar, asegúrate de haber pegado el código en tu bio',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
        success ? const Color(0xFF1C1C1E) : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: Duration(seconds: success ? 2 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HANDLE ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── TÍTULO ─────────────────────────────────────────
              const Text(
                'Verificación pendiente',
                style: TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // ── DESCRIPCIÓN ────────────────────────────────────
              const Text(
                'Para completar la verificación debes colocar el código en tu biografía o descripción de perfil para verificar tu cuenta',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // ── CARD DE LA CUENTA ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFE5E5EA), width: 1.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      _getPlatformIcon(widget.account.platform),
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.account.platform[0].toUpperCase() +
                                widget.account.platform
                                    .substring(1)
                                    .toLowerCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.account.displayUsername,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/images/akar-icons_edit.png',
                        width: 28,
                        height: 28,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── CÓDIGO + COPIAR ─────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Código
                  Text(
                    widget.account.verificationCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Ícono copiar nativo
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                          text: widget.account.verificationCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Código copiado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1C1C1E),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 22,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── INFO DEBAJO DEL CÓDIGO ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: Color(0xFF8E8E93)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Una vez verificado el código puedes eliminarlo de tu biografía',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              // ── ERROR MESSAGE ───────────────────────────────────
              if (_hasError) ...[
                const SizedBox(height: 14),
                const Text(
                  'No se ha podido verificar la cuenta, asegúrate de copiar el código correctamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── BOTÓN VERIFICAR ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2A2A2A),
                        Color(0xFF000000),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.18),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isVerifying
                        ? null
                        : () async {
                      setState(() {
                        _isVerifying = true;
                        _hasError = false;
                      });
                      final success = await widget.onVerify();
                      if (mounted) {
                        if (success) {
                          _showToast(success: true);
                          await Future.delayed(
                              const Duration(seconds: 2));
                          if (mounted) Navigator.pop(context);
                        } else {
                          setState(() {
                            _isVerifying = false;
                            _hasError = true;
                          });
                          _showToast(success: false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Verificar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── BOTÓN MÁS TARDE ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onLater?.call();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F7),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Más tarde',
                    style: TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}