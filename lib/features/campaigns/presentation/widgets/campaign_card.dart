import 'package:flutter/material.dart';
import 'package:inklop_v1/features/campaigns/data/models/campaign_model.dart';
import 'budget_progress_bar.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // Fila Superior: Logo, Título y CPM
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    campaign.image,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🔥 La más popular',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'USD ${campaign.budget.cpm}/1k',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Barra de Progreso del Presupuesto
            BudgetProgressBar(
              spent: campaign.budget.spent,
              total: campaign.budget.total,
              percentage: campaign.budget.percentage,
            ),

            const SizedBox(height: 20),

            // Fila Inferior: Info extra y Plataformas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo('Tipo', campaign.creatorType),
                _miniInfo('Categoría', campaign.categories.isNotEmpty ? campaign.categories.first : 'N/A'),
                Row(
                  children: [
                    if (campaign.allowsTiktok) const Icon(Icons.music_note, size: 20, color: Colors.black),
                    const SizedBox(width: 6),
                    if (campaign.allowsInstagram) const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.black),
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
}