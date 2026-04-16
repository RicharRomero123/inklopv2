import 'package:flutter/material.dart';
import '../../data/dashboard_api_service.dart';
import '../../data/models/submission_model.dart';
import '../../data/models/creator_metrics_model.dart'; // 🚀 Import del modelo
import '../widgets/metric_card.dart';                // 🚀 Import del widget
import '../widgets/active_campaign_card.dart';
import '../widgets/content_grid_item.dart';
import '../widgets/content_header.dart';
import 'submission_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String accessToken;
  const DashboardScreen({super.key, required this.accessToken});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = DashboardApiService();

  List<UserSubmission>? _allSubmissions;
  CreatorMetrics? _metrics;

  bool _loading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // Llamada simultánea a Railway
    final results = await Future.wait([
      _api.getCreatorSubmissions(widget.accessToken),
      _api.getCreatorMetrics(widget.accessToken),
    ]);

    if (mounted) {
      setState(() {
        _allSubmissions = results[0] as List<UserSubmission>?;
        _metrics = results[1] as CreatorMetrics?;
        _loading = false;
      });
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return '$views';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TÍTULO MORADO ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B1FA8), Color(0xFF0D0018)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: const Text('Tus Métricas',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          ),

          // ── TARJETAS DE MÉTRICAS (Usando la clase MetricCard) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _loading
                ? _buildMetricSkeleton()
                : IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Vistas Totales',
                      value: _formatViews(_metrics?.totalViews ?? 0),
                      iconPath: 'assets/images/ic_ojos.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Postulaciones',
                      value: '${_metrics?.totalSubmissions ?? 0}',
                      iconPath: 'assets/images/bxs_videos.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Engagement',
                      value: '${_metrics?.engagement.toStringAsFixed(1) ?? "0.0"}%',
                      iconPath: 'assets/images/stash_engagement.png',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── CONTENIDO SCROLLEABLE ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.black,
              child: CustomScrollView(
                slivers: [
                  _buildCampaignsHeaderSliver(),
                  _buildCampaignsListSliver(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ContentHeader(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (f) => setState(() => _selectedFilter = f),
                      ),
                    ),
                  ),
                  _buildGridSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildMetricSkeleton() {
    return Row(children: List.generate(3, (i) => Expanded(
      child: Container(margin: EdgeInsets.only(right: i < 2 ? 12 : 0), height: 100,
          decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(22))),
    )));
  }

  Widget _buildCampaignsHeaderSliver() {
    return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, 14),
        child: Text('Campañas Activas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));
  }

  Widget _buildCampaignsListSliver() {
    final campaigns = _allSubmissions?.map((s) => s.campaign).toSet().toList() ?? [];
    if (campaigns.isEmpty) {
      return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Sin campañas activas', style: TextStyle(color: Colors.grey, fontSize: 13))));
    }
    return SliverToBoxAdapter(child: SizedBox(height: 150, child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: campaigns.length, itemBuilder: (_, i) => ActiveCampaignCard(campaign: campaigns[i], accessToken: widget.accessToken))));
  }

  Widget _buildGridSliver() {
    final list = _filteredList;
    if (list.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Sin contenido aquí aún', style: TextStyle(color: Colors.grey)))));
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.62),
          delegate: SliverChildBuilderDelegate((context, i) => ContentGridItem(submission: list[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmissionDetailScreen(submissions: list, initialIndex: i, accessToken: widget.accessToken)))), childCount: list.length),
        ));
  }

  List<UserSubmission> get _filteredList {
    if (_allSubmissions == null) return [];
    switch (_selectedFilter) {
      case 'Aceptados': return _allSubmissions!.where((s) => s.submissionStatus == 'APPROVED').toList();
      case 'Pendientes': return _allSubmissions!.where((s) => s.submissionStatus == 'PENDING' || s.submissionStatus == 'ERROR').toList();
      case 'Denegados': return _allSubmissions!.where((s) => s.submissionStatus == 'REJECTED').toList();
      default: return _allSubmissions!;
    }
  }
}