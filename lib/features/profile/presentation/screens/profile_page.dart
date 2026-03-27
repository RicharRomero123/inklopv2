import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/profile_api_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../../../social_media/presentation/screens/social_media_link_screen.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;
  const ProfilePage({super.key, required this.accessToken});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileApiService _apiService = ProfileApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getMyProfile(widget.accessToken);
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  // --- WIDGET SKELETON (CARGA) ---
  Widget _buildSkeleton({required double width, required double height, double borderRadius = 12}) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadius)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay datos y no está cargando, mostramos error
    if (!_isLoading && _userData == null) {
      return const Scaffold(body: Center(child: Text("Error al cargar perfil")));
    }

    final List allSocials = _userData?['socialMedias'] ?? [];
    final verifiedAccounts = allSocials.where((s) => s['isVerified'] == true).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: FOTO CUADRADA REDONDEADA Y STATS ---
              Row(
                children: [
                  _isLoading
                      ? _buildSkeleton(width: 95, height: 95, borderRadius: 28)
                      : Container(
                    width: 95, height: 95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: _userData?['avatarUrl'] != null
                          ? DecorationImage(image: NetworkImage(_userData!['avatarUrl']), fit: BoxFit.cover)
                          : null,
                      color: Colors.grey[100],
                    ),
                    child: _userData?['avatarUrl'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const Spacer(),
                  _buildStatColumn('12', 'Campañas'),
                  _buildStatColumn(
                      _isLoading ? '...' : '${_userData?['wallet']['balancePEN']}',
                      'Saldo (S/)'
                  ),
                  _buildStatColumn('s/1.5k', 'Ganancias'),
                ],
              ),
              const SizedBox(height: 18),

              // --- BOTONES: EDITAR PERFIL Y CONFIGURACIÓN ---
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: _isLoading
                          ? _buildSkeleton(width: double.infinity, height: 44, borderRadius: 22)
                          : FilledButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => EditProfileScreen(accessToken: widget.accessToken, initialData: _userData!)
                        )).then((_) => _loadProfile()),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1C1C1E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))
                        ),
                        child: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isLoading
                      ? _buildSkeleton(width: 44, height: 44, borderRadius: 22)
                      : Container(
                    height: 44, width: 44,
                    decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => SettingsScreen(accessToken: widget.accessToken)
                      )).then((_) => _loadProfile()),
                      icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- NOMBRE Y USERNAME ---
              _isLoading
                  ? _buildSkeleton(width: 200, height: 28)
                  : Text(
                  '${_userData?['names']} ${_userData?['lastNames']}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)
              ),
              const SizedBox(height: 4),
              _isLoading
                  ? _buildSkeleton(width: 120, height: 18)
                  : Text('@${_userData?['username']}', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),

              const SizedBox(height: 14),

              // --- DESCRIPCIÓN ---
              _isLoading
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: 6),
                _buildSkeleton(width: 250, height: 16),
              ])
                  : Text(
                  _userData?['description'] ?? 'Sin descripción aún...',
                  style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF3A3A3C))
              ),

              const SizedBox(height: 18),

              // --- UBICACIÓN Y FECHA (ICONOS GRISES) ---
              Row(
                children: [
                  const Icon(Icons.public, size: 18, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  _isLoading ? _buildSkeleton(width: 80, height: 14) : Text('${_userData?['city']}, ${_userData?['country']}', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
                  const SizedBox(width: 20),
                  const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  _isLoading ? _buildSkeleton(width: 100, height: 14) : const Text('Se unió el 21 Nov', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 35),

              // --- SECCIÓN REDES VINCULADAS ---
              const Text('Redes vinculadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 18),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_isLoading)
                      ...List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: _buildSkeleton(width: 65, height: 85, borderRadius: 18),
                      ))
                    else ...[
                      ...verifiedAccounts.map((social) => _buildSocialItem(
                        platform: social['platform'],
                        nickname: social['nickname'] ?? 'user',
                      )),
                      _buildAddAccount(context),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Columnas de estadísticas
  Widget _buildStatColumn(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  // Ítem de Red Social (Squircle gris)
  Widget _buildSocialItem({required String platform, required String nickname}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: platform.toLowerCase() == 'tiktok'
                  ? const Icon(Icons.music_note, size: 32, color: Colors.black)
                  : const Icon(Icons.camera_alt, size: 30, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Text('@$nickname', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Botón Agregar Cuenta
  Widget _buildAddAccount(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => SocialMediaLinkScreen(accessToken: widget.accessToken)
      )).then((_) => _loadProfile()),
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text('Agregar', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}