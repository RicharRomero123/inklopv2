import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inklop_v1/features/main/presentation/main_screen.dart';
import 'package:inklop_v1/features/social_media/data/models/social_media_model.dart';
import 'package:inklop_v1/features/social_media/data/social_media_api_service.dart';
import '../widgets/url_input_modal.dart';
import '../widgets/verification_modal.dart';

class SocialMediaLinkScreen extends StatefulWidget {
  final String accessToken;
  const SocialMediaLinkScreen({super.key, required this.accessToken});

  @override
  State<SocialMediaLinkScreen> createState() => _SocialMediaLinkScreenState();
}

class _SocialMediaLinkScreenState extends State<SocialMediaLinkScreen> {
  final _apiService = SocialMediaApiService();
  List<SocialMediaAccount> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() => _isLoading = true);
    final list = await _apiService.getMySocialMedias(widget.accessToken);
    setState(() {
      _accounts = list;
      _isLoading = false;
    });
  }

  // --- LÓGICA DE CONEXIÓN ---
  void _openUrlModal(String platform) {
    // Aquí 'platform' ya viene como "TIKTOK" o "INSTAGRAM"
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => UrlInputModal(
        platform: platform,
        onConfirm: (url) async {
          Navigator.pop(context);
          // 🚀 ENVIANDO AL POST: "TIKTOK" o "INSTAGRAM"
          final newAcc = await _apiService.linkAccount(platform, url, widget.accessToken);
          if (newAcc != null) {
            _fetchAccounts();
            _openVerificationModal(newAcc);
          }
        },
      ),
    );
  }

  void _openVerificationModal(SocialMediaAccount account) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => VerificationModal(
        account: account,
        onVerify: () async {
          final success = await _apiService.verifyAccount(account.id, widget.accessToken);
          if (success && mounted) {
            Navigator.pop(context);
            _fetchAccounts();
            return true;
          }
          return false;
        },
      ),
    );
  }

  // Helper para iconos de plataforma
  Widget _getPlatformIcon(String platform, {double size = 24}) {
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        return Icon(Icons.music_note, color: Colors.black, size: size);
      case 'INSTAGRAM':
        return Icon(Icons.camera_alt, color: Colors.pink, size: size);
      default:
        return Icon(Icons.link, color: Colors.grey, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canContinue = _accounts.any((a) => a.isVerified);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black)
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.travel_explore, size: 60, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 24),
            const Text(
                'Vincula tus redes sociales',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
            ),
            const SizedBox(height: 8),
            const Text(
                'Conecta tu TikTok e Instagram para comenzar a monetizar tu contenido.',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15, height: 1.4)
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.black)))
            else
              Expanded(
                child: ListView(
                  children: [
                    // Cuentas ya vinculadas
                    ..._accounts.map((acc) => _buildAccountItem(acc)),

                    const SizedBox(height: 12),
                    const Text('Conectar nuevas cuentas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),

                    // 🚀 BOTONES DE CONEXIÓN DINÁMICOS
                    _buildConnectBtn('TikTok', 'TIKTOK'),
                    const SizedBox(height: 12),
                    _buildConnectBtn('Instagram', 'INSTAGRAM'),
                  ],
                ),
              ),

            // Botón de Continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: canContinue
                    ? () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen(accessToken: widget.accessToken))
                )
                    : null,
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget para las cuentas ya agregadas (Squircle)
  Widget _buildAccountItem(SocialMediaAccount acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100)
      ),
      child: Row(
        children: [
          _getPlatformIcon(acc.platform),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc.displayUsername, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                      acc.isVerified ? 'Verificado' : 'Pendiente de verificación',
                      style: TextStyle(
                          color: acc.isVerified ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600
                      )
                  ),
                ]
            ),
          ),
          if (!acc.isVerified)
            IconButton(
                icon: const Icon(Icons.fact_check_outlined, color: Colors.blue),
                onPressed: () => _openVerificationModal(acc)
            ),
          IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () async {
                if (await _apiService.deleteAccount(acc.id, widget.accessToken)) _fetchAccounts();
              }
          ),
        ],
      ),
    );
  }

  // Widget para el botón de conectar (Estilo Inklop)
  Widget _buildConnectBtn(String label, String platformKey) {
    return InkWell(
      onTap: () => _openUrlModal(platformKey), // Envía "TIKTOK" o "INSTAGRAM"
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200)
        ),
        child: Row(
          children: [
            _getPlatformIcon(platformKey),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            const Text('Conectar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}