import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/profile_api_service.dart';
import '../../../social_media/data/social_media_api_service.dart';

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

  // Helper para mostrar iconos genéricos mientras no tienes los PNGs
  Widget _getPlatformIcon(String platform) {
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        return const Icon(Icons.music_note, color: Colors.black, size: 24);
      case 'INSTAGRAM':
        return const Icon(Icons.camera_alt, color: Colors.pink, size: 24);
      default:
        return const Icon(Icons.link, color: Colors.blue, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _allAccounts.where((s) => s['isVerified'] == true).toList();
    final pending = _allAccounts.where((s) => s['isVerified'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader('Mis Cuentas'),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Cuentas Conectadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (connected.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No hay cuentas verificadas', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ...connected.map((acc) => _buildAccountCard(acc)),

                  const SizedBox(height: 24),
                  const Text('Pendiente a Verificación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No hay verificaciones pendientes', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ...pending.map((acc) => _buildPendingCard(acc)),

                  const SizedBox(height: 32),
                  const Text('Conectar Cuentas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildConnectRow('TikTok'),
                  _buildConnectRow('Instagram'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1F0533), Color(0xFF0D0214)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)
          ),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Map acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          _getPlatformIcon(acc['platform']), // Icono genérico
          const SizedBox(width: 12),
          Text(acc['nickname'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await _socialApi.deleteAccount(acc['id'], widget.accessToken);
                _load();
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          children: [
            Row(
              children: [
                _getPlatformIcon(acc['platform']), // Icono genérico
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(acc['platform'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Sin verificar', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      acc['verificationCode'] ?? '---',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.blueGrey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: acc['verificationCode'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado'), duration: Duration(seconds: 1)));
                    }
                ),
                IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await _socialApi.deleteAccount(acc['id'], widget.accessToken);
                      _load();
                    }
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: FilledButton(
                onPressed: isVerifying ? null : () async {
                  setInternalState(() => isVerifying = true);
                  final ok = await _socialApi.verifyAccount(acc['id'], widget.accessToken);
                  if (ok) {
                    _load();
                  } else {
                    setInternalState(() => isVerifying = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aún no se detecta el código en tu perfil')));
                  }
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
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

  Widget _buildConnectRow(String platform) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          _getPlatformIcon(platform), // Icono genérico
          const SizedBox(width: 12),
          Text(platform, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
              onPressed: () {
                // Aquí iría tu lógica de abrir el modal para pegar el link
              },
              child: const Text('Conectar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
          ),
        ],
      ),
    );
  }
}