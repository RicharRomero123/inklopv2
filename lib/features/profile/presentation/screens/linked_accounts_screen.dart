import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/profile_api_service.dart';
import '../../../social_media/data/social_media_api_service.dart';
import '../../../social_media/presentation/widgets/url_input_modal.dart'; // Asegúrate de importar tu modal

class LinkedAccountsScreen extends StatefulWidget {
  final String accessToken;
  const LinkedAccountsScreen({super.key, required this.accessToken});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final _profileApi = ProfileApiService();
  final _socialApi = SocialMediaApiService();
  List _allAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _profileApi.getMyProfile(widget.accessToken);
    setState(() {
      _allAccounts = data?['socialMedias'] ?? [];
      _isLoading = false;
    });
  }

  // 🚀 Helper para usar tus iconos PNG
  Widget _getPlatformIcon(String platform, {double size = 24}) {
    String assetPath;
    switch (platform.toLowerCase()) {
      case 'tiktok':
        assetPath = 'assets/images/ic_tiktok.png';
        break;
      case 'instagram':
        assetPath = 'assets/images/ic_instagram.png';
        break;
      default:
        return Icon(Icons.link, color: Colors.grey, size: size);
    }
    return Image.asset(assetPath, width: size, height: size);
  }

  @override
  Widget build(BuildContext context) {
    final connected = _allAccounts.where((s) => s['isVerified'] == true).toList();
    final pending = _allAccounts.where((s) => s['isVerified'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, 'Mis Cuentas'),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.black)))
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  _sectionLabel('Cuentas Conectadas'),
                  const SizedBox(height: 12),
                  if (connected.isEmpty)
                    _emptyText('No hay cuentas verificadas')
                  else
                    ...connected.map((acc) => _buildAccountCard(acc)),

                  const SizedBox(height: 32),
                  _sectionLabel('Pendiente a Verificación'),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    _emptyText('No hay verificaciones pendientes')
                  else
                    ...pending.map((acc) => _buildPendingCard(acc)),

                  const SizedBox(height: 32),
                  _sectionLabel('Conectar Cuentas'),
                  const SizedBox(height: 12),
                  _buildConnectRow('TikTok', 'TIKTOK'),
                  _buildConnectRow('Instagram', 'INSTAGRAM'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── HEADER PREMIUM (ESTILO PROFILE/SETTINGS) ──────────────────────────────
  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 8,
        right: 24,
        bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B1FA8), Color(0xFF3D0D6B), Color(0xFF0D0018)],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 8, right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── CARDS Y FILAS ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.3));
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(text, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
    );
  }

  Widget _buildAccountCard(Map acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: const Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(18)
      ),
      child: Row(
        children: [
          _getPlatformIcon(acc['platform']),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
                acc['nickname'] ?? 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
            ),
          ),
          IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              onPressed: () async {
                if (await _socialApi.deleteAccount(acc['id'], widget.accessToken)) _load();
              }
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map acc) {
    bool isVerifying = false;
    return StatefulBuilder(
      builder: (context, setInternalState) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E5EA)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          children: [
            Row(
              children: [
                _getPlatformIcon(acc['platform']),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(acc['platform'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Text('Pendiente', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                      acc['verificationCode'] ?? '---',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 13, color: Colors.blueGrey)
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.copy_all_rounded, size: 20, color: Color(0xFF1C1C1E)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: acc['verificationCode'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado')));
                    }
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isVerifying ? null : () async {
                  setInternalState(() => isVerifying = true);
                  final ok = await _socialApi.verifyAccount(acc['id'], widget.accessToken);
                  if (ok) {
                    _load();
                  } else {
                    setInternalState(() => isVerifying = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código no detectado en tu perfil')));
                  }
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                ),
                child: isVerifying
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verificar ahora', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildConnectRow(String label, String platformKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(18)
      ),
      child: Row(
        children: [
          _getPlatformIcon(platformKey),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: () => _openUrlModal(platformKey),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('Conectar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 Llama a tu modal de URL que ya configuramos antes
  void _openUrlModal(String platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UrlInputModal(
        platform: platform,
        onConfirm: (url) async {
          final newAcc = await _socialApi.linkAccount(platform, url, widget.accessToken);
          if (newAcc != null) {
            if (mounted) Navigator.pop(context);
            _load();
          } else {
            throw Exception("duplicate key value");
          }
        },
      ),
    );
  }
}