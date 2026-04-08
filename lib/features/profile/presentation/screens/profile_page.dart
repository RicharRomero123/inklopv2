import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inklop_v1/features/profile/presentation/screens/linked_accounts_screen.dart';
import '../../data/profile_api_service.dart';
import '../../../social_media/data/social_media_api_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;
  const ProfilePage({super.key, required this.accessToken});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileApiService _apiService = ProfileApiService();
  final SocialMediaApiService _socialApi = SocialMediaApiService();
  Map<String, dynamic>? _userData;
  List _verifiedAccounts = [];
  bool _isLoading = true;

  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
    _loadProfile();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Cargamos perfil y cuentas en paralelo
    final results = await Future.wait([
      _apiService.getMyProfile(widget.accessToken),
      _socialApi.getAccountsByUser(widget.accessToken),
    ]);

    if (mounted) {
      setState(() {
        _userData = results[0] as Map<String, dynamic>?;
        final allAccounts = (results[1] as List?) ?? [];
        _verifiedAccounts =
            allAccounts.where((s) => s['isVerified'] == true).toList();
        _isLoading = false;
      });
    }
  }

  String _formatJoinDate(String? isoDate) {
    if (isoDate == null) return 'Fecha desconocida';
    try {
      final DateTime date = DateTime.parse(isoDate);
      const months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return 'Error de fecha';
    }
  }

  Widget _skeleton({
    required double width,
    required double height,
    double radius = 12,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, __) => Opacity(
        opacity: _shimmerAnim.value,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  bool get _showSkeleton => _isLoading || _userData == null;

  @override
  Widget build(BuildContext context) {
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

              // ── HEADER ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showSkeleton
                      ? _skeleton(width: 88, height: 100, radius: 25)
                      : Container(
                    width: 88,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFFE5E5EA),
                      image: _userData?['avatarUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(_userData!['avatarUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _userData?['avatarUrl'] == null
                        ? const Icon(Icons.person,
                        size: 42, color: Colors.grey)
                        : null,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _showSkeleton
                                ? List.generate(
                              3,
                                  (_) => Column(
                                children: [
                                  _skeleton(
                                      width: 36, height: 18, radius: 8),
                                  const SizedBox(height: 5),
                                  _skeleton(
                                      width: 52, height: 11, radius: 6),
                                ],
                              ),
                            )
                                : [
                              _buildStatColumn('12', 'Campañas'),
                              _buildStatColumn('15k', 'Visualizaciones'),
                              _buildStatColumn('s/1.5k', 'Ganancias'),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: FilledButton(
                                    onPressed: _showSkeleton
                                        ? null
                                        : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProfileScreen(
                                              accessToken:
                                              widget.accessToken,
                                              initialData: _userData!,
                                            ),
                                      ),
                                    ).then((_) => _loadProfile()),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _showSkeleton
                                          ? const Color(0xFFE5E5EA)
                                          : const Color(0xFF1C1C1E),
                                      disabledBackgroundColor:
                                      const Color(0xFFE5E5EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: _showSkeleton
                                        ? const SizedBox.shrink()
                                        : const Text(
                                      'Editar Perfil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: FilledButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SettingsScreen(
                                          accessToken: widget.accessToken),
                                    ),
                                  ).then((_) => _loadProfile()),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C1C1E),
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

              // ── NOMBRE Y USERNAME ────────────────────────────────────
              _showSkeleton
                  ? _skeleton(width: 200, height: 24, radius: 10)
                  : Text(
                '${_userData?['names']} ${_userData?['lastNames']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              _showSkeleton
                  ? _skeleton(width: 110, height: 15, radius: 8)
                  : Text(
                '@${_userData?['username']}',
                style: const TextStyle(
                    color: Color(0xFF8E8E93), fontSize: 15),
              ),

              const SizedBox(height: 12),

              // ── DESCRIPCIÓN ──────────────────────────────────────────
              _showSkeleton
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeleton(
                      width: double.infinity, height: 14, radius: 8),
                  const SizedBox(height: 6),
                  _skeleton(width: 200, height: 14, radius: 8),
                ],
              )
                  : Text(
                _userData?['description'] ?? 'Sin descripción aún...',
                style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Color(0xFF1C1C1E)),
              ),

              const SizedBox(height: 14),

              // ── UBICACIÓN Y FECHA ────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.public,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 5),
                  _showSkeleton
                      ? _skeleton(width: 80, height: 13, radius: 6)
                      : Text(
                    '${_userData?['city']}, ${_userData?['country']}',
                    style: const TextStyle(
                        color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                  const SizedBox(width: 18),
                  const Icon(Icons.calendar_month_outlined,
                      size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 5),
                  _showSkeleton
                      ? _skeleton(width: 100, height: 13, radius: 6)
                      : Text(
                    'Se unió el ${_formatJoinDate(_userData?['createdAt'])}',
                    style: const TextStyle(
                        color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ── REDES VINCULADAS ─────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _showSkeleton
                      ? List.generate(
                    3,
                        (_) => Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: Column(
                        children: [
                          _skeleton(
                              width: 68, height: 68, radius: 18),
                          const SizedBox(height: 7),
                          _skeleton(width: 56, height: 12, radius: 6),
                        ],
                      ),
                    ),
                  )
                      : [
                    ..._verifiedAccounts.map(
                          (social) => _buildSocialItem(social),
                    ),
                    _buildAddAccount(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT COLUMN ──────────────────────────────────────────────────────────
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
          style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }

  // ── SOCIAL ITEM — avatar + badge de plataforma + nickname ────────────────
  Widget _buildSocialItem(Map social) {
    final String? avatarUrl = social['avatar'];
    final String platform = social['platform'] ?? '';
    final String nickname = social['nickname'] ?? social['name_account'] ?? 'user';

    String platformAsset;
    switch (platform.toLowerCase()) {
      case 'tiktok':
        platformAsset = 'assets/images/ic_tiktok.png';
        break;
      case 'instagram':
        platformAsset = 'assets/images/ic_instagram.png';
        break;
      default:
        platformAsset = '';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        children: [
          // Avatar con badge de plataforma
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar del perfil
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFE5E5EA),
                  image: avatarUrl != null
                      ? DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 32, color: Colors.grey)
                    : null,
              ),
              // Badge ícono red social — esquina inferior derecha
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: platformAsset.isNotEmpty
                      ? Image.asset(platformAsset, fit: BoxFit.contain)
                      : const Icon(Icons.link, size: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '@$nickname',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── AGREGAR CUENTA ───────────────────────────────────────────────────────
  Widget _buildAddAccount(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LinkedAccountsScreen(accessToken: widget.accessToken),
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
            'Agregar',
            style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}