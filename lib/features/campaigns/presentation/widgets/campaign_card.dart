import 'package:flutter/material.dart';
import 'package:inklop_v1/features/campaigns/data/models/campaign_model.dart';
import 'budget_progress_bar.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const CampaignCard({super.key, required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isPopular = campaign.quantitySubmissions > 5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: const Color(0xFFF2F2F7)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyLogo(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2, // ← Cambiado de 1 a 2
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (isPopular) _buildPopularBadge(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildCpmBadge(),
              ],
            ),
            const SizedBox(height: 16),
            BudgetProgressBar(
              spent: campaign.budget.spent,
              total: campaign.budget.total,
              percentage: campaign.budget.percentage,
            ),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        campaign.businessImage,
        width: 45,
        height: 45,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 45,
          height: 45,
          color: Colors.grey[200],
          child: const Icon(Icons.business, size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/ic_fire.png',
            width: 12,
            height: 12,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'La más popular',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCpmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'USD ${campaign.budget.cpm.toStringAsFixed(2)}/1k',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniItem('Tipo', campaign.creatorType),
        _miniItem(
          'Categoría',
          campaign.categories.isNotEmpty ? campaign.categories.first : 'UGC',
        ),
        // ← Label "Plataforma" encima de los iconos
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plataforma',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (campaign.allowsTiktok)
                  Image.asset(
                    'assets/images/ic_tiktok.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (c, e, s) =>
                    const Icon(Icons.music_note, size: 16),
                  ),
                if (campaign.allowsTiktok && campaign.allowsInstagram)
                  const SizedBox(width: 8),
                if (campaign.allowsInstagram)
                  Image.asset(
                    'assets/images/ic_instagram.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (c, e, s) =>
                    const Icon(Icons.camera_alt, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}