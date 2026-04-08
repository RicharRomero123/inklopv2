import 'package:flutter/material.dart';
import '../../data/models/submission_model.dart';

class ContentGridItem extends StatelessWidget {
  final UserSubmission submission;
  final VoidCallback onTap;

  const ContentGridItem({super.key, required this.submission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = submission.submissionStatus;

    // Color y label según status
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'APPROVED':
        statusColor = const Color(0xFF34C759);
        statusLabel = 'Aceptado';
        break;
      case 'REJECTED':
        statusColor = const Color(0xFFFF3B30);
        statusLabel = 'Denegado';
        break;
      default:
        statusColor = const Color(0xFFFF9500);
        statusLabel = 'Pendiente';
    }

    // Vistas formateadas: 12125 → "12,125"
    final String viewsFormatted = _formatViews(submission.post.views);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── IMAGEN DE FONDO ─────────────────────────────────────
            Image.network(
              submission.post.displayImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2C2C2E)),
            ),

            // ── DEGRADADO SUPERIOR (para badges) ────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── DEGRADADO INFERIOR (para pago) ───────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── BADGE VISTAS (arriba izquierda) ─────────────────────
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_red_eye_outlined,
                        color: Colors.white, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      viewsFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BADGE STATUS (arriba derecha) ────────────────────────
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            // ── PAGO (abajo izquierda) ───────────────────────────────
            Positioned(
              bottom: 12, left: 12,
              child: Text(
                'S/${submission.payment?.netPayment ?? '0.00'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(dynamic views) {
    try {
      final int n = int.parse(views.toString());
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
      return n.toString();
    } catch (_) {
      return views.toString();
    }
  }
}