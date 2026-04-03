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

  String _formatJoinDate(String? isoDate) {
    if (isoDate == null) return "Fecha desconocida";
    try {
      final DateTime date = DateTime.parse(isoDate);
      final List<String> months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return "${date.day} ${months[date.month - 1]}";
    } catch (e) {
      return "Error de fecha";
    }
  }

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return 'assets/images/profile_tiktok.png';
      case 'instagram':
        return 'assets/images/profile_ig.png';
      default:
        return 'assets/images/ic_profile.png';
    }
  }

  Widget _buildSkeleton({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _userData == null) {
      return const Scaffold(
        body: Center(child: Text("Error al cargar perfil")),
      );
    }

    final List allSocials = _userData?['socialMedias'] ?? [];
    final verifiedAccounts =
    allSocials.where((s) => s['isVerified'] == true).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER: FOTO | STATS + BOTONES ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto rectangular con bordes redondeados
                  _isLoading
                      ? _buildSkeleton(width: 88, height: 100, borderRadius: 16)
                      : Container(
                    width: 88,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      image: _userData?['avatarUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(_userData!['avatarUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: _userData?['avatarUrl'] == null
                        ? const Icon(Icons.person,
                        size: 42, color: Colors.grey)
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Columna derecha: Stats arriba, Botones abajo
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('12', 'Campañas'),
                              _buildStatColumn('15k', 'Visualizaciones'),
                              _buildStatColumn('s/1.5k', 'Ganancias'),
                            ],
                          ),

                          // Botones Editar + Settings
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: _isLoading
                                      ? _buildSkeleton(
                                    width: double.infinity,
                                    height: 40,
                                    borderRadius: 20,
                                  )
                                      : FilledButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(
                                          accessToken: widget.accessToken,
                                          initialData: _userData!,
                                        ),
                                      ),
                                    ).then((_) => _loadProfile()),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFF1C1C1E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Editar Perfil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _isLoading
                                  ? _buildSkeleton(
                                  width: 40,
                                  height: 40,
                                  borderRadius: 20)
                                  : SizedBox(
                                width: 40,
                                height: 40,
                                child: FilledButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SettingsScreen(
                                          accessToken:
                                          widget.accessToken),
                                    ),
                                  ).then((_) => _loadProfile()),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF1C1C1E),
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                  ),
                                  child: const Icon(Icons.settings,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── NOMBRE Y USERNAME ─────────────────────────────────────
              _isLoading
                  ? _buildSkeleton(width: 200, height: 26)
                  : Text(
                '${_userData?['names']} ${_userData?['lastNames']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              _isLoading
                  ? _buildSkeleton(width: 110, height: 16)
                  : Text(
                '@${_userData?['username']}',
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 12),

              // ── DESCRIPCIÓN ───────────────────────────────────────────
              _isLoading
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeleton(
                      width: double.infinity, height: 15),
                  const SizedBox(height: 5),
                  _buildSkeleton(width: 220, height: 15),
                ],
              )
                  : Text(
                _userData?['description'] ?? 'Sin descripción aún...',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF1C1C1E),
                ),
              ),

              const SizedBox(height: 14),

              // ── UBICACIÓN Y FECHA ─────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.public,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 5),
                  _isLoading
                      ? _buildSkeleton(width: 70, height: 13)
                      : Text(
                    '${_userData?['city']}, ${_userData?['country']}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Icon(Icons.calendar_month_outlined,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 5),
                  _isLoading
                      ? _buildSkeleton(width: 90, height: 13)
                      : Text(
                    'Se unió el ${_formatJoinDate(_userData?['createdAt'])}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ── REDES VINCULADAS ──────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_isLoading)
                      ...List.generate(
                        3,
                            (i) => Padding(
                          padding: const EdgeInsets.only(right: 22),
                          child: _buildSkeleton(
                              width: 68, height: 90, borderRadius: 16),
                        ),
                      )
                    else ...[
                      ...verifiedAccounts.map(
                            (social) => _buildSocialItem(
                          platform: social['platform'],
                          nickname: social['nickname'] ?? 'user',
                        ),
                      ),
                      _buildAddAccount(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT COLUMN ───────────────────────────────────────────────────────────
  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  // ── SOCIAL ITEM ───────────────────────────────────────────────────────────
  Widget _buildSocialItem({
    required String platform,
    required String nickname,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Image.asset(
                _getPlatformIcon(platform),
                width: 30,
                height: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '@$nickname',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTÓN AGREGAR CUENTA ──────────────────────────────────────────────────
  Widget _buildAddAccount(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SocialMediaLinkScreen(accessToken: widget.accessToken),
        ),
      ).then((_) => _loadProfile()),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 7),
          const Text(
            'Agregar cuenta',
            style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}