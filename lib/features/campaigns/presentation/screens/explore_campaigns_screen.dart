// lib/features/campaigns/presentation/screens/explore_campaigns_screen.dart
import 'package:flutter/material.dart';
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
  final _apiService    = CampaignApiService();
  final _searchCtrl    = TextEditingController();
  final _searchFocus   = FocusNode();

  List<Campaign>? _campaigns;
  bool   _isLoading     = true;
  String _selectedFilter = 'Todos';
  String _searchQuery    = '';

  final List<String> _filters = [
    'Todos',
    'Más Populares',
    'Más Pagados',
    'Más Recientes',
  ];

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadData() async {
    // Nota: El RefreshIndicator ya muestra su propio spinner,
    // pero mantenemos _isLoading para la carga inicial.
    if (_campaigns == null) setState(() => _isLoading = true);

    final data = await _apiService.getActiveCampaigns(widget.accessToken);

    if (mounted) {
      setState(() {
        _campaigns  = data;
        _isLoading  = false;
      });
    }
  }

  // ── 1. ORDENAMIENTO ────────────────────────────────────────────────
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

  // ── 2. FILTRADO POR BÚSQUEDA ───────────────────────────────────────
  List<Campaign> get _displayedCampaigns {
    final sorted = _sortedCampaigns;
    if (_searchQuery.isEmpty) return sorted;

    return sorted.where((c) {
      final title   = c.title.toLowerCase();
      final company = (c.businessName ?? c.title ?? '').toLowerCase();
      return title.contains(_searchQuery) || company.contains(_searchQuery);
    }).toList();
  }

  // ── BUILD ───────────────────────────────────────────────────────────
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
            // 🚀 REFRESH INDICATOR: El gesto nativo de "Jalar para actualizar"
            child: RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              displacement: 20,
              onRefresh: _loadData,
              child: _isLoading ? _buildSkeleton() : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────
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
              const Text(
                'Explora Oportunidades',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Image.asset('assets/images/hugeicons_notification-01.png', width: 26, height: 26, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Busca una campaña o empresa',
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchCtrl.clear())
                  : null,
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

  Widget _buildSectionTitle() {
    final total = _displayedCampaigns.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Campañas Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (_searchQuery.isNotEmpty) Text('$total resultado${total == 1 ? '' : 's'}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
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
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
              shape: const StadiumBorder(side: BorderSide.none),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // ── LISTA (Con soporte para AlwaysScrollable) ──────────────────────
  Widget _buildList() {
    final campaigns = _displayedCampaigns;

    if (campaigns.isEmpty) {
      return ListView(
        // 🚀 Permite que el Pull-to-Refresh funcione aun si la lista está vacía
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay campañas disponibles', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      // 🚀 Forzamos el scroll para que el RefreshIndicator siempre responda
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: campaigns.length,
      itemBuilder: (context, index) => CampaignCard(
        campaign: campaigns[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetailScreen(
              campaign: campaigns[index],
              accessToken: widget.accessToken,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() => const Center(child: CircularProgressIndicator(color: Colors.black));
}