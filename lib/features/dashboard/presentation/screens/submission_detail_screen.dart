import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inklop_v1/features/dashboard/presentation/widgets/appeal_modal.dart';
import '../../data/models/submission_model.dart';
import '../../data/dashboard_api_service.dart';

class SubmissionDetailScreen extends StatefulWidget {
  final List<UserSubmission> submissions;
  final int initialIndex;
  final String accessToken;

  const SubmissionDetailScreen({
    super.key,
    required this.submissions,
    required this.initialIndex,
    required this.accessToken,
  });

  @override
  State<SubmissionDetailScreen> createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final _api = DashboardApiService();

  // viewportFraction 0.52 → cada frame ocupa el 52% del ancho de pantalla
  // En 390px → ~203px ancho. Con ratio 9:16 → alto ≈ 360px
  // El carrusel tiene height = 368 para que respire
  static const double _carouselHeight = 368;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.52,
    );
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? _currentIndex;
      if (next != _currentIndex) setState(() => _currentIndex = next);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  UserSubmission get _current => widget.submissions[_currentIndex];

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':  return const Color(0xFF34C759);
      case 'REJECTED':  return const Color(0xFFFF9500);
      case 'ON_APPEAL': return const Color(0xFF007AFF);
      case 'ERROR':     return const Color(0xFFFF3B30);
      default:          return const Color(0xFFFF9500);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'APPROVED':  return 'Aceptado';
      case 'REJECTED':  return 'Denegado';
      case 'ON_APPEAL': return 'En Apelación';
      case 'ERROR':     return 'Error';
      default:          return 'Pendiente';
    }
  }

  String _formatNum(dynamic n) {
    try {
      final int v = int.parse(n.toString());
      if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000)    return '${(v / 1000).toStringAsFixed(1)}K';
      return v.toString();
    } catch (_) {
      return n.toString();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _monthName(int m) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[m - 1];
  }

  String _timeLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'a.m.' : 'p.m.';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final sub    = _current;
    final status = sub.submissionStatus;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          ),
        ),
        title: const Text(
          'Analíticas del video',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── CARRUSEL 9:16 ───────────────────────────────────────────
          SizedBox(
            height: _carouselHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.submissions.length,
              itemBuilder: (_, i) {
                final s        = widget.submissions[i];
                final isCenter = i == _currentIndex;

                return AnimatedScale(
                  scale:    isCenter ? 1.0 : 0.78,
                  duration: const Duration(milliseconds: 300),
                  curve:    Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity:  isCenter ? 1.0 : 0.40,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      // Padding mínimo: deja que los laterales se recorten
                      // naturalmente por el SizedBox del carrusel
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        // AspectRatio 9:16 — siempre vertical, nunca cuadrado
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Image.network(
                            s.post.displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFF2C2C2E)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── LINK DEL VIDEO — centrado, debajo del carrusel ──────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: GestureDetector(
                onTap: () => _launchUrl(sub.post.videoUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Link del Video',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      SizedBox(width: 7),
                      Icon(Icons.open_in_new,
                          color: Colors.white, size: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── CONTENIDO SCROLLEABLE ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── INFO CREADOR ────────────────────────────────────
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sub.socialMedia.avatar,
                          width: 48, height: 48, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48, height: 48,
                            color: const Color(0xFFE5E5EA),
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                sub.socialMedia.nameAccount,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 4),
                              const Text('♪', style: TextStyle(fontSize: 14)),
                            ]),
                            Text(
                              sub.campaign.title,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Enviado el ${sub.createdAt.day} '
                                  '${_monthName(sub.createdAt.month)} '
                                  'de ${sub.createdAt.year} '
                                  'a las ${_timeLabel(sub.createdAt)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── CAPTION ─────────────────────────────────────────
                  Text(
                    sub.post.caption,
                    style: const TextStyle(
                        fontSize: 13, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 22),

                  // ── ESTADÍSTICAS — centradas, íconos 24px, valor debajo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem(
                        iconPath: 'assets/images/mdi_eye.png',
                        value: _formatNum(sub.post.views),
                      ),
                      _statItem(
                        iconPath: 'assets/images/line-md_heart-filled.png',
                        value: _formatNum(sub.post.likes),
                      ),
                      _statItem(
                        iconPath: 'assets/images/iconamoon_comment-fill.png',
                        value: _formatNum(sub.post.comments),
                      ),
                      _statItem(
                        iconPath: 'assets/images/majesticons_share.png',
                        value: _formatNum(sub.post.shares),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── MÉTRICAS INFERIORES ─────────────────────────────
                  Row(children: [
                    Expanded(
                      child: _metricBox(
                        iconPath: 'assets/images/mdi_eye.png',
                        label: 'Visualizaciones',
                        value: _formatNum(sub.post.views),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricBox(
                        iconPath: 'assets/images/si_money-fill.png',
                        label: 'Pago Acumulado',
                        value: sub.payment != null
                            ? 'S/${sub.payment!.netPayment.toStringAsFixed(2)}'
                            : '-',
                      ),
                    ),
                  ]),

                  // ── MOTIVO DE RECHAZO (pill colapsable) ─────────────
                  if (sub.isRejected || sub.isOnAppeal) ...[
                    const SizedBox(height: 16),
                    _RejectionPill(description: sub.description),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(sub),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────────────────────
  Widget _buildBottomBar(UserSubmission sub) {
    final isApproved = sub.isApproved;
    final isRejected = sub.isRejected;
    final isOnAppeal = sub.isOnAppeal;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isApproved ? () => _showPaymentModal(sub) : null,
                icon: Image.asset(
                  'assets/images/wallet-02.png',
                  width: 20, height: 20,
                  color: isApproved ? Colors.white : Colors.grey,
                ),
                label: Text(
                  isApproved
                      ? 'Cobrar  S/${sub.payment?.netPayment.toStringAsFixed(2) ?? '0.00'}'
                      : 'Cobrar',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApproved
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  foregroundColor: isApproved ? Colors.white : Colors.grey,
                  disabledBackgroundColor: const Color(0xFFF2F2F7),
                  disabledForegroundColor: Colors.grey,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ),

          if (isRejected && !isOnAppeal) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => AppealModal.show(
                context,
                sub.submissionId,
                    (reason) async {
                  final success = await _api.sendAppeal(
                    token: widget.accessToken,
                    submissionId: sub.submissionId,
                    reason: reason,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'Apelación enviada con éxito'
                          : 'Error al enviar apelación'),
                    ));
                  }
                },
              ),
              child: Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/ic_flag.png',
                    width: 22, height: 22,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],

          if (isOnAppeal) ...[
            const SizedBox(width: 12),
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFF007AFF), size: 22),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── STAT ITEM — ícono arriba, valor abajo, centrado ─────────────────
  Widget _statItem({
    required String iconPath,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          width: 24, height: 24,
          color: const Color(0xFF1C1C1E),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _metricBox({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset(iconPath, width: 16, height: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _showPaymentModal(UserSubmission sub) {
    // TODO: implementar modal de cobro
  }
}

// ── PILL COLAPSABLE DE RECHAZO ──────────────────────────────────────────
class _RejectionPill extends StatefulWidget {
  final String description;
  const _RejectionPill({required this.description});

  @override
  State<_RejectionPill> createState() => _RejectionPillState();
}

class _RejectionPillState extends State<_RejectionPill>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Motivo de rechazo',
                    style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const Spacer(),
                  RotationTransition(
                    turns: _rotate,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFFF3B30),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _fade,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xFFFFE8E8))),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                        height: 1.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}