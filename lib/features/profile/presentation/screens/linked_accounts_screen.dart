import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../social_media/data/social_media_api_service.dart';
import '../../data/profile_api_service.dart';
import '../../../social_media/presentation/widgets/url_input_modal.dart';

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
    final data = await _socialApi.getAccountsByUser(widget.accessToken); // ✅ corregido
    setState(() {
      _allAccounts = data ?? [];
      _isLoading = false;
    });
  }

  Widget _getPlatformIcon(String platform, {double size = 28}) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return Image.asset('assets/images/ic_tiktok.png',
            width: size, height: size);
      case 'instagram':
        return Image.asset('assets/images/ic_instagram.png',
            width: size, height: size);
      default:
        return Icon(Icons.link, color: Colors.grey, size: size);
    }
  }

  // ── CONFIRMAR ELIMINACIÓN — VERIFICADA (con mensaje soporte) ──────────────
  Future<void> _confirmDeleteVerified(Map acc) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ic_alerta.png', width: 52, height: 52),
            const SizedBox(height: 16),
            const Text(
              'Eliminar cuenta',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF1C1C1E)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Al eliminar una cuenta verificada deberás contactar a soporte para cualquier cambio. Los pagos y métricas asociadas se conservan como historial interno.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF6B6B6E), height: 1.55),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C1C1E),
                    side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Cancelar',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Eliminar',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _socialApi.deleteAccount(acc['id'], widget.accessToken);
      _load();
    }
  }

  // ── CONFIRMAR ELIMINACIÓN — NO VERIFICADA (simple) ────────────────────────
  Future<void> _confirmDeletePending(Map acc) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Eliminar cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF1C1C1E)),
            ),
            SizedBox(height: 10),
            Text(
              '¿Estás seguro que deseas eliminar esta cuenta pendiente?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF6B6B6E), height: 1.55),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C1C1E),
                    side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Cancelar',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Eliminar',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _socialApi.deleteAccount(acc['id'], widget.accessToken);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected =
    _allAccounts.where((s) => s['isVerified'] == true).toList();
    final pending =
    _allAccounts.where((s) => s['isVerified'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, 'Mis Cuentas'),
          if (_isLoading)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(color: Colors.black)))
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  _sectionLabel('Cuentas Conectadas'),
                  const SizedBox(height: 14),
                  if (connected.isEmpty)
                    _emptyText('No hay cuentas verificadas')
                  else
                    ...connected.map((acc) => _buildAccountCard(acc)),

                  if (pending.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _sectionLabel('Pendiente a Verificación'),
                    const SizedBox(height: 14),
                    ...pending.map((acc) => _buildPendingCard(acc)),
                  ],

                  const SizedBox(height: 28),
                  _sectionLabel('Conectar Cuentas'),
                  const SizedBox(height: 14),
                  _buildConnectRow('TikTok', 'TIKTOK'),
                  _buildConnectRow('Instagram', 'INSTAGRAM'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
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
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
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

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.3));
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(text,
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
    );
  }

  // ── CARD CUENTA VERIFICADA ────────────────────────────────────────────────
  Widget _buildAccountCard(Map acc) {
    final String? avatarUrl = acc['avatar'];
    final String name = acc['name_account'] ?? acc['nickname'] ?? 'Usuario';
    final String? nickname = acc['nickname'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF2F2F7),
              backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 22, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: -2,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _getPlatformIcon(acc['platform'] ?? '', size: 14),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: nickname != null
            ? Text(
          '@$nickname',
          style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w400),
        )
            : null,
        trailing: GestureDetector(
          onTap: () => _confirmDeleteVerified(acc),
          child: Image.asset('assets/images/ic_basura.png',
              width: 22, height: 22),
        ),
      ),
    );
  }

  // ── CARD PENDIENTE ────────────────────────────────────────────────────────
  Widget _buildPendingCard(Map acc) {
    bool isVerifying = false;

    final String rawLink = acc['link'] ?? '';
    final String displayLink = rawLink
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');

    return StatefulBuilder(
      builder: (context, setInternalState) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _getPlatformIcon(acc['platform'] ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayLink,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF3A3A3C)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Código de verificación',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            acc['verificationCode'] ?? '---',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: acc['verificationCode'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Código copiado')));
                            },
                            child: const Icon(Icons.copy_rounded,
                                size: 16, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  GestureDetector(
                    onTap: () => _confirmDeletePending(acc),
                    child: Image.asset('assets/images/ic_basura.png',
                        width: 20, height: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                    setInternalState(() => isVerifying = true);
                    final ok = await _socialApi.verifyAccount(
                        acc['id'], widget.accessToken);
                    if (ok) {
                      _load();
                    } else {
                      setInternalState(() => isVerifying = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Código no detectado en tu perfil')));
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text(
                    'Verificar',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILA CONECTAR ─────────────────────────────────────────────────────────
  Widget _buildConnectRow(String label, String platformKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _getPlatformIcon(platformKey),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: () => _openUrlModal(platformKey),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: const Text(
                'Conectar',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── MODAL URL ─────────────────────────────────────────────────────────────
  void _openUrlModal(String platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UrlInputModal(
        platform: platform,
        onConfirm: (url) async {
          final newAcc =
          await _socialApi.linkAccount(platform, url, widget.accessToken);
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