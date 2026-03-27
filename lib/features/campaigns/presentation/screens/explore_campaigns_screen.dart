import 'package:flutter/material.dart';
import '../../data/campaign_api_service.dart';
import '../../data/models/campaign_model.dart';
import 'campaign_detail_screen.dart';

class ExploreCampaignsScreen extends StatefulWidget {
  final String accessToken;
  const ExploreCampaignsScreen({super.key, required this.accessToken});

  @override
  State<ExploreCampaignsScreen> createState() => _ExploreCampaignsScreenState();
}

class _ExploreCampaignsScreenState extends State<ExploreCampaignsScreen> {
  final _apiService = CampaignApiService();
  List<Campaign>? _campaigns;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getActiveCampaigns(widget.accessToken);
    setState(() {
      _campaigns = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? _buildSkeletonList()
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _campaigns?.length ?? 0,
                itemBuilder: (context, index) => _buildCampaignCard(_campaigns![index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D0A4E), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Explora Oportunidades', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              Icon(Icons.notifications_none, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            decoration: InputDecoration(
              hintText: 'Busca una campaña',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Campaign camp) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => CampaignDetailScreen(campaign: camp, accessToken: widget.accessToken)
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(camp.image, width: 55, height: 55, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(camp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                        child: const Text('🔥 La más popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(12)),
                  child: Text('USD ${camp.budget.cpm}/1k', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('USD ${camp.budget.spent} pagados', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('de USD ${camp.budget.total} presupuesto', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: camp.budget.percentage / 100,
                backgroundColor: Colors.grey[100],
                color: const Color(0xFF9C27B0),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo('Tipo', camp.creatorType),
                _miniInfo('Categoría', camp.categories.first),
                Row(
                  children: [
                    if(camp.allowsTiktok) const Icon(Icons.music_note, size: 20),
                    const SizedBox(width: 4),
                    if(camp.allowsInstagram) const Icon(Icons.camera_alt_outlined, size: 20),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 200, margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}