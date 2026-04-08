import 'package:flutter/material.dart';
import 'package:inklop_v1/features/campaigns/data/models/campaign_model.dart';
import 'package:inklop_v1/features/campaigns/presentation/screens/campaign_detail_screen.dart';
import '../../data/models/submission_model.dart';
// Al inicio del archivo, agrega este import:
import 'package:inklop_v1/features/campaigns/data/models/campaign_model.dart';
class ActiveCampaignCard extends StatelessWidget {
  final CampaignMini campaign;
  final String accessToken;

  const ActiveCampaignCard({
    super.key,
    required this.campaign,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final tags = campaign.categories.take(2).toList();
    final bool hasTiktok = campaign.hashtags.any((h) => h.toLowerCase().contains('tiktok'));
    // Si tienes flags en CampaignMini agrégalos; por ahora inferimos de hashtags
    // y mostramos socialMedia del modelo si está disponible

    return GestureDetector(
      onTap: () {
        // Navegamos al detalle usando idCampaign
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetailScreen(
              // CampaignDetailScreen recibe Campaign, no CampaignMini
              // Construimos un Campaign mínimo desde CampaignMini
              campaign: _toFullCampaign(campaign),
              accessToken: accessToken,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF2F2F7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── HEADER: logo + título + CPM ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo campaña
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      campaign.image,
                      width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52, height: 52,
                        color: Colors.grey[100],
                        child: const Icon(Icons.business, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Título + tipo creador
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 3),
                            Text(
                              campaign.creatorType,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // CPM Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${campaign.budget.cpm.toStringAsFixed(1)}/1K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── DIVIDER ──────────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey.shade100),

            // ── FOOTER: stats + redes + categorías ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pago mín - máx
                  _footerStat(
                    icon: Icons.attach_money,
                    label: 'Pago',
                    value: '\$ ${campaign.budget.minPayment.toStringAsFixed(0)} - ${campaign.budget.maxPayment.toStringAsFixed(0)}',),

                  // Presupuesto gastado %
                  _footerStat(
                    icon: Icons.pie_chart_outline,
                    label: 'Uso',
                    value: '${campaign.budget.percentage.toInt()}%',
                  ),

                  // Categorías como chips
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: tags
                          .map((t) => _miniTag(t))
                          .toList(),
                    ),

                  // Redes sociales
                  _socialIcons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Íconos de redes (TikTok / Instagram) ─────────────────────────────────
  Widget _socialIcons() {
    // Inferimos plataformas desde hashtags o campaignStatus
    // Si tu CampaignMini tuviese allowsTiktok/allowsInstagram úsalos directamente
    final bool showTiktok = true;   // ajusta con tu lógica real
    final bool showInstagram = true;

    return Row(
      children: [
        if (showTiktok)
          _socialChip('assets/images/ic_tiktok.png', Icons.music_note),
        if (showInstagram) ...[
          const SizedBox(width: 5),
          _socialChip('assets/images/ic_instagram.png', Icons.camera_alt),
        ],
      ],
    );
  }

  Widget _socialChip(String asset, IconData fallback) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        width: 15, height: 15,
        errorBuilder: (_, __, ___) =>
            Icon(fallback, size: 14, color: Colors.grey[700]),
      ),
    );
  }

  Widget _footerStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 10, color: Colors.grey),
          const SizedBox(width: 2),
          Text(label,
              style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ]),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _miniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Convertir CampaignMini → Campaign para el detalle ────────────────────
  Campaign _toFullCampaign(CampaignMini mini) {
    return Campaign(
      id: mini.idCampaign,
      title: mini.title,
      image: mini.image,
      businessImage: mini.image,
      businessName: '',
      description: mini.description,
      creatorType: mini.creatorType,
      status: mini.campaignStatus,
      categories: mini.categories,
      hashtags: mini.hashtags,
      allowsTiktok: false,
      allowsInstagram: false,
      quantitySubmissions: 0,
      budget: CampaignBudget(
        total: mini.budget.totalBudget,
        spent: mini.budget.spentBudget,
        percentage: mini.budget.percentage,
        cpm: mini.budget.cpm,
        minPayment: mini.budget.minPayment,
        maxPayment: mini.budget.maxPayment,
      ),
      metrics: CampaignMetrics(
        durationInDays: 0,
        daysRemaining: 0,
        percentageElapsed: 0.0,
      ),
    );
  }
}