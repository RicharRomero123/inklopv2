import 'package:flutter/material.dart';
import '../../data/profile_api_service.dart';
import '../widgets/stat_item.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart'; // Asegúrate de tener este import
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

  String _parseUsername(String link) {
    if (link.contains('@')) return '@${link.split('@').last}';
    return link.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (_userData == null) return const Center(child: Text("No se pudo cargar el perfil"));

    // 🚀 FILTRO: Solo tomamos las cuentas donde isVerified es true
    final List allSocials = _userData!['socialMedias'] ?? [];
    final verifiedAccounts = allSocials.where((s) => s['isVerified'] == true).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Foto y Stats
              Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _userData!['avatarUrl'] != null
                        ? NetworkImage(_userData!['avatarUrl'])
                        : null,
                    child: _userData!['avatarUrl'] == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const Spacer(),
                  const StatItem(label: 'Campañas', value: '0'),
                  StatItem(label: 'Saldo (S/)', value: '${_userData!['wallet']['balancePEN']}'),
                  const StatItem(label: 'Ganancias', value: 'S/0'),
                ],
              ),
              const SizedBox(height: 20),

              // BOTONES
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => EditProfileScreen(accessToken: widget.accessToken, initialData: _userData!)
                        ));
                        _loadProfile();
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                      ),
                      child: const Text('Editar Perfil'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de configuración (La tuerca)
                  IconButton.filledTonal(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => SettingsScreen(accessToken: widget.accessToken)
                        )).then((_) => _loadProfile());
                      },
                      icon: const Icon(Icons.settings)
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // INFO PERSONAL
              Text(_userData!['realName'] ?? 'Sin nombre', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('@${_userData!['username']}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Text(_userData!['description'] ?? 'Escribe algo sobre ti...', style: const TextStyle(height: 1.4)),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  Text(' ${_userData!['city']}, ${_userData!['country']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 32),

              // SECCIÓN DE REDES SOCIALES (SOLO VERIFICADAS)
              const Text('Redes vinculadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Mapeamos SOLO las cuentas verificadas
                    ...verifiedAccounts.map((social) {
                      return _buildSocialCircle(
                        platform: social['platform'],
                        username: _parseUsername(social['link']),
                      );
                    }),

                    // Botón de agregar cuenta (siempre visible)
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

  Widget _buildSocialCircle({required String platform, required String username}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey[200]!)
                ),
                child: Image.asset(
                  'assets/images/${platform.toLowerCase()}_logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.link, size: 32),
                ),
              ),
              // Como solo mostramos verificadas aquí, el check siempre va
              const CircleAvatar(radius: 8, backgroundColor: Colors.white, child: Icon(Icons.check_circle, color: Colors.blue, size: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(username, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAddAccount(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => SocialMediaLinkScreen(accessToken: widget.accessToken)
      )).then((_) => _loadProfile()),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid)
            ),
            child: const Icon(Icons.add, size: 32, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text('Agregar', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}