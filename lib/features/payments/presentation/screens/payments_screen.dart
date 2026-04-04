// lib/features/payments/presentation/screens/payments_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/stripe_api_service.dart';
import 'wallet_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final String accessToken;
  const PaymentsScreen({super.key, required this.accessToken});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _apiService = StripeApiService();
  double _amount = 0.0;
  String _currency = "USD";
  bool _isLoading = true;

  // Datos simulados del gráfico (reemplazar con datos reales)
  final List<double> _chartData = [
    120, 180, 160, 220, 190, 280, 240, 320, 290, 380,
    350, 410, 390, 460, 440, 520, 500, 580, 560, 640,
    610, 680, 660, 720, 700, 780, 760, 840, 820, 900,
  ];
  final List<String> _chartLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final data = await _apiService.getBalance(widget.accessToken);
    if (data != null && mounted) {
      setState(() {
        _amount = (data['amount'] as num).toDouble();
        _currency = data['currency'];
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance + chart section (white bg, no padding top)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: _buildBalanceSection(),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Cobros',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Center(
                          child: Text(
                            'Aún no realizaste cobros',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER con degradado oscuro → morado ─────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 8,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6B1FA8), // morado vivo arriba
            Color(0xFF3D0D6B), // morado oscuro medio
            Color(0xFF0D0018), // negro con tinte morado abajo
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mis Pagos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/images/ic_notification_home.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── BALANCE + badges + botón billetera ───────────────────────────────────
  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título + botón billetera
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ganancias Totales',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
            // Botón Mi Billetera — negro, pill, icono asset
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletScreen(
                    accessToken: widget.accessToken,
                    initialBalance: _amount,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_wallet.png',
                      width: 15,
                      height: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Mi Billetera',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Monto grande
        _isLoading
            ? const SizedBox(
          height: 52,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
        )
            : _buildAmountText(),

        const SizedBox(height: 10),

        // Badges
        Row(
          children: [
            _badge('Pagado: 0.00', const Color(0xFF06C167)),
            const SizedBox(width: 10),
            _badge('En Proceso: 0.00', const Color(0xFFFF9500)),
          ],
        ),
      ],
    );
  }

  // Tipografía del monto — parte entera grande, decimales más pequeños
  Widget _buildAmountText() {
    final parts = _amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'SF Pro Display', // usa la fuente del sistema en iOS
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: -2,
        ),
        children: [
          TextSpan(
            text: '$_currency \$$intPart',
            style: const TextStyle(fontSize: 46),
          ),
          TextSpan(
            text: '.$decPart',
            style: const TextStyle(fontSize: 28, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── GRÁFICO de área interactivo ──────────────────────────────────────────
  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: GestureDetector(
        onTapDown: (d) => _onChartTap(d.localPosition),
        onPanUpdate: (d) => _onChartTap(d.localPosition),
        child: CustomPaint(
          painter: _AreaChartPainter(
            data: _chartData,
            selectedIndex: _selectedIndex,
            labels: _chartLabels,
          ),
          size: Size(MediaQuery.of(context).size.width, 200),
        ),
      ),
    );
  }

  void _onChartTap(Offset pos) {
    final chartWidth = MediaQuery.of(context).size.width;
    final step = chartWidth / (_chartData.length - 1);
    final idx = (pos.dx / step).round().clamp(0, _chartData.length - 1);
    setState(() => _selectedIndex = idx);
  }
}

// ── CHART PAINTER ────────────────────────────────────────────────────────────
class _AreaChartPainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;
  final List<String> labels;

  _AreaChartPainter({
    required this.data,
    required this.selectedIndex,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double bottomPad = 36; // espacio para labels X
    const double topPad = 16;
    final chartH = size.height - bottomPad - topPad;
    final chartW = size.width;

    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    // Calcular puntos
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * chartW;
      final y = topPad + chartH - ((data[i] - minVal) / range) * chartH;
      points.add(Offset(x, y));
    }

    // Path de la línea (suave con cubicTo)
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }

    // Path del área (cierra hacia abajo)
    final areaPath = Path.from(linePath);
    areaPath.lineTo(chartW, size.height - bottomPad);
    areaPath.lineTo(0, size.height - bottomPad);
    areaPath.close();

    // Gradiente del área (negro → gris muy claro)
    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.12),
        Colors.black.withOpacity(0.0),
      ],
    );
    final areaPaint = Paint()
      ..shader = areaGradient.createShader(
        Rect.fromLTWH(0, topPad, chartW, chartH),
      );
    canvas.drawPath(areaPath, areaPaint);

    // Línea principal
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Labels eje X
    final labelStyle = const TextStyle(
      color: Color(0xFFAAAAAA),
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
    final labelPositions = [0, 7, 14, 21, 28]; // índices aproximados para Jan..May
    for (int i = 0; i < labels.length && i < labelPositions.length; i++) {
      final idx = labelPositions[i].clamp(0, data.length - 1);
      final x = (idx / (data.length - 1)) * chartW;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 10));
    }

    // Punto seleccionado + tooltip
    if (selectedIndex != null) {
      final sel = selectedIndex!;
      final pt = points[sel];

      // Línea vertical punteada
      final dashedPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 1;
      const dashH = 6.0;
      const gapH = 4.0;
      double y = topPad;
      while (y < size.height - bottomPad) {
        canvas.drawLine(Offset(pt.dx, y), Offset(pt.dx, min(y + dashH, size.height - bottomPad)), dashedPaint);
        y += dashH + gapH;
      }

      // Punto negro
      canvas.drawCircle(pt, 5, Paint()..color = Colors.black);
      canvas.drawCircle(pt, 3, Paint()..color = Colors.white);

      // Tooltip oscuro
      final value = '\$${data[sel].toStringAsFixed(0)}';
      final tpTooltip = TextPainter(
        text: TextSpan(
          text: value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const tooltipPad = EdgeInsets.symmetric(horizontal: 12, vertical: 7);
      final tooltipW = tpTooltip.width + tooltipPad.horizontal;
      final tooltipH = tpTooltip.height + tooltipPad.vertical;
      var tooltipX = pt.dx - tooltipW / 2;
      tooltipX = tooltipX.clamp(4.0, chartW - tooltipW - 4);
      final tooltipY = pt.dy - tooltipH - 12;

      final tooltipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH),
        const Radius.circular(10),
      );
      canvas.drawRRect(tooltipRect, Paint()..color = Colors.black);
      tpTooltip.paint(
        canvas,
        Offset(tooltipX + tooltipPad.left, tooltipY + tooltipPad.top),
      );
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) =>
      old.selectedIndex != selectedIndex || old.data != data;
}