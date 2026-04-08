import 'package:flutter/material.dart';

class CampaignSubmissionsScreen extends StatelessWidget {
  final List<dynamic> submissions;
  final String campaignTitle;

  const CampaignSubmissionsScreen({
    super.key,
    required this.submissions,
    required this.campaignTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0018),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(campaignTitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Text("Mis Envíos",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];
                return _buildSubmissionCard(sub);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(dynamic sub) {
    final post = sub['post'] ?? {};
    final payment = sub['payment'] ?? {};
    final status = sub['submissionStatus'] ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post['display_image'] ?? '',
              width: 80, height: 110, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white10, width: 80, height: 110, child: const Icon(Icons.videocam, color: Colors.white24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge(status),
                    Text(
                      "USD ${payment['paymentData']?['netPayment']?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Color(0xFF00FFA3), fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _stat(Icons.remove_red_eye_outlined, "${post['views'] ?? 0}"),
                    const SizedBox(width: 15),
                    _stat(Icons.favorite_border, "${post['likes'] ?? 0}"),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Enviado el ${_formatDate(sub['createdAt'])}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'APPROVED') color = Colors.greenAccent;
    if (status == 'REJECTED') color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _stat(IconData icon, String val) {
    return Row(children: [
      Icon(icon, color: Colors.white54, size: 14),
      const SizedBox(width: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  String _formatDate(String? iso) {
    if (iso == null) return "--/--/--";
    final d = DateTime.parse(iso);
    return "${d.day}/${d.month}/${d.year}";
  }
}