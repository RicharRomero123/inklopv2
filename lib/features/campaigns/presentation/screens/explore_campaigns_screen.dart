import 'package:flutter/material.dart';
import 'package:inklop_v1/features/auth/data/auth_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/campaign_api_service.dart';
import '../../data/models/campaign_model.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';

class ExploreCampaignsScreen extends StatefulWidget {
  final String accessToken;
  const ExploreCampaignsScreen({super.key, required this.accessToken});

  @override
  State<ExploreCampaignsScreen> createState() => _ExploreCampaignsScreenState();
}

class _ExploreCampaignsScreenState extends State<ExploreCampaignsScreen> {
  final _apiService      = CampaignApiService();
  final _authService     = AuthService();
  final _storageService  = SecureStorageService();

  final _searchCtrl      = TextEditingController();
  final _searchFocus     = FocusNode();

  List<Campaign>? _campaigns;
  bool   _isLoading      = true;
  String _selectedFilter = 'Todos';
  String _searchQuery    = '';

  late String _currentAccessToken;

  final List<String> _filters = [
    'Todos',
    'Más Populares',
    'Más Pagados',
    'Más Recientes',
  ];

  @override
  void initState() {
    super.initState();
    _currentAccessToken = widget.accessToken;
    _loadData();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── LÓGICA DE CARGA CON PRINTS DE DEPURACIÓN ──────────────────────────────
  Future<void> _loadData() async {
    if (_campaigns == null) setState(() => _isLoading = true);

    debugPrint("--- 🔄 INICIANDO PROCESO DE CARGA/REFRESH ---");

    try {
      // 1. Obtener Refresh Token del Storage
      final String? storedRefreshToken = await _storageService.getRefreshToken();

      debugPrint("🔑 Refresh Token en Storage: ${storedRefreshToken ?? 'NULO'}");
      debugPrint("🛑 Access Token Actual (Antes): ${_currentAccessToken.substring(_currentAccessToken.length - 15)}");

      if (storedRefreshToken != null) {
        // 2. Intentar renovar
        final newTokens = await _authService.renewToken(storedRefreshToken);
        final String? newToken = newTokens['token'];
        final String? newRefresh = newTokens['refreshToken'];

        if (newToken != null) {
          debugPrint("🆕 Access Token Nuevo (Después): ${newToken.substring(newToken.length - 15)}");

          // Comparación directa para saber si Auth0 te está dando lo mismo
          if (newToken == _currentAccessToken) {
            debugPrint("⚠️ ADVERTENCIA: Auth0 devolvió exactamente el mismo token.");
          } else {
            debugPrint("✅ ÉXITO: El token ha cambiado.");
          }

          // Guardar en Storage
          await _storageService.saveToken(
            access: newToken,
            refresh: newRefresh ?? storedRefreshToken,
          );

          // Actualizar variable local
          setState(() {
            _currentAccessToken = newToken;
          });
        }
      }

      // 3. Petición a la API
      debugPrint("📡 Llamando a la API con el token final...");
      final data = await _apiService.getActiveCampaigns(_currentAccessToken);

      if (mounted) {
        setState(() {
          _campaigns  = data;
          _isLoading  = false;
        });
      }
    } catch (e) {
      debugPrint("❌ ERROR CRÍTICO EN EXPLORE: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    debugPrint("--- ✅ FIN DEL PROCESO ---");
  }

  // ── MÉTODOS DE UI (Sin cambios) ──────────────────────────────────────────
  List<Campaign> get _sortedCampaigns {
    if (_campaigns == null) return [];
    List<Campaign> list = List.from(_campaigns!);
    switch (_selectedFilter) {
      case 'Más Populares':
        list.sort((a, b) => b.quantitySubmissions.compareTo(a.quantitySubmissions));
        break;
      case 'Más Pagados':
        list.sort((a, b) => b.budget.total.compareTo(a.budget.total));
        break;
      case 'Más Recientes':
        list.sort((a, b) => (b.metrics.startDate ?? '').compareTo(a.metrics.startDate ?? ''));
        break;
      default:
        list.sort((a, b) => (b.metrics.startDate ?? '').compareTo(a.metrics.startDate ?? ''));
    }
    return list;
  }

  List<Campaign> get _displayedCampaigns {
    final sorted = _sortedCampaigns;
    if (_searchQuery.isEmpty) return sorted;
    return sorted.where((c) {
      final title   = c.title.toLowerCase();
      final company = (c.businessName ?? c.title ?? '').toLowerCase();
      return title.contains(_searchQuery) || company.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(topPadding),
          _buildSectionTitle(),
          _buildFilterRow(),
          Expanded(
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: _loadData,
              child: _isLoading ? _buildSkeleton() : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B1FA8), Color(0xFF0D0018)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Explora Oportunidades', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: 'Busca una campaña o empresa',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() => const Padding(
    padding: EdgeInsets.fromLTRB(24, 20, 24, 4),
    child: Text('Campañas Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildFilterRow() => SizedBox(
    height: 52,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filters.length,
      itemBuilder: (context, index) {
        final filter = _filters[index];
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            selectedColor: const Color(0xFF1C1C1E),
            backgroundColor: const Color(0xFFF2F2F7),
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            shape: const StadiumBorder(side: BorderSide.none),
            showCheckmark: false,
          ),
        );
      },
    ),
  );

  Widget _buildList() {
    final campaigns = _displayedCampaigns;
    if (campaigns.isEmpty) return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text('No hay campañas', style: TextStyle(color: Colors.grey))))]);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: campaigns.length,
      itemBuilder: (context, index) => CampaignCard(
        campaign: campaigns[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: campaigns[index], accessToken: _currentAccessToken)),
        ),
      ),
    );
  }

  Widget _buildSkeleton() => const Center(child: CircularProgressIndicator(color: Colors.black));
}