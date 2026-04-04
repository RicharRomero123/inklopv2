import 'package:flutter/material.dart';
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

  // Constantes de diseño para consistencia
  static const double _cardRadius = 18.0;
  static const Color _lightGreyBg = Color(0xFFF9F9F9);
  static const Color _textGrey = Color(0xFF8E8E93);

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

  // --- LÓGICA DE CONEXIÓN (Mantenida) ---
  void _openUrlModal(String platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => UrlInputModal(
        platform: platform,
        onConfirm: (url) async {
          final newAcc = await _apiService.linkAccount(platform, url, widget.accessToken);
          if (newAcc != null) {
            if (mounted) Navigator.pop(context);
            _fetchAccounts();
            _openVerificationModal(newAcc);
          } else {
            throw Exception("duplicate key value");
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
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

  // 🚀 Helper para usar los iconos PNG solicitados
  Widget _getPlatformIcon(String platform, {double size = 28}) {
    String assetName;
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        assetName = 'assets/images/ic_tiktok.png';
        break;
      case 'INSTAGRAM':
        assetName = 'assets/images/ic_instagram.png';
        break;
      default:
        return Icon(Icons.link, color: _textGrey, size: size);
    }
    return Image.asset(assetName, width: size, height: size, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    bool canContinue = _accounts.any((a) => a.isVerified);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header centrado con icono grande y limpio
            const Center(
              child: Icon(Icons.travel_explore, size: 70, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 32),

            // Título con estilo premium (Grande, Bold, Negrita)
            const Text(
              'Vincula tus redes sociales',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.0),
            ),
            const SizedBox(height: 10),

            // Subtítulo con buen interlineado
            const Text(
              'Conecta tu TikTok e Instagram para comenzar a monetizar tu contenido.',
              style: TextStyle(color: _textGrey, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.black)))
            else
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(), // Scroll suave estilo iOS
                  children: [
                    // Mapeo de cuentas ya agregadas con diseño squircle
                    ..._accounts.map((acc) => _buildAccountItem(acc)),

                    if (_accounts.isNotEmpty) const SizedBox(height: 24),

                    const Text(
                      'Conectar nuevas cuentas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 16),

                    // 🚀 Botones de conexión transformados en tarjetas premium
                    _buildConnectCard('TikTok', 'TIKTOK'),
                    const SizedBox(height: 12),
                    _buildConnectCard('Instagram', 'INSTAGRAM'),
                    const SizedBox(height: 40), // Espacio extra antes del botón final
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
                  MaterialPageRoute(
                    builder: (_) => MainScreen(accessToken: widget.accessToken),
                  ),
                )
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE DISEÑO MEJORADOS ---

  // 1. Widget para las cuentas en lista ( Squircle premium )
  Widget _buildAccountItem(SocialMediaAccount acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _lightGreyBg,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _getPlatformIcon(acc.platform),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    acc.displayUsername,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))
                ),
                const SizedBox(height: 2),
                Text(
                  acc.isVerified ? 'Verificado' : 'Pendiente de verificación',
                  style: TextStyle(
                    color: acc.isVerified ? Colors.green : Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Acciones alineadas
          if (!acc.isVerified)
            IconButton(
              icon: const Icon(Icons.fact_check_outlined, color: Colors.blue, size: 22),
              onPressed: () => _openVerificationModal(acc),
              constraints: const BoxConstraints(), // Quita padding extra
              padding: const EdgeInsets.all(8),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
            onPressed: () async {
              if (await _apiService.deleteAccount(acc.id, widget.accessToken)) _fetchAccounts();
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  // 2. Widget para el botón de conectar plataformas ( Transformado en Tarjeta Interactiva )
  Widget _buildConnectCard(String label, String platformKey) {
    return InkWell(
      onTap: () => _openUrlModal(platformKey),
      borderRadius: BorderRadius.circular(_cardRadius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: Colors.grey.shade200),
            // Sombra muy sutil para dar profundidad
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Row(
          children: [
            _getPlatformIcon(platformKey),
            const SizedBox(width: 16),
            Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A1A1A))
            ),
            const Spacer(),

            // Indicador de acción alineado a la derecha
            const Text(
                'Conectar',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 14)
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}