import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/stripe_api_service.dart';
import '../../data/models/stripe_models.dart';
import 'wallet_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final String accessToken;
  const PaymentsScreen({super.key, required this.accessToken});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _apiService = StripeApiService();

  // 💰 Datos de Balance (API /balance)
  double _currentBalance = 0.0;
  double _pendingBalance = 0.0;
  String _currency = "USD";
  bool _isLoading = true;

  // 📊 Datos de Historial (API /payout-history)
  StripePayoutHistory? _history;
  List<double> _chartData = [0, 0, 0, 0, 0];
  List<String> _chartLabels = ['-', '-', '-', '-', '-'];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getBalance(widget.accessToken),
        _apiService.getPayoutHistory(widget.accessToken),
      ]);

      final balanceData = results[0] as Map<String, dynamic>?;
      final historyData = results[1] as StripePayoutHistory?;

      if (mounted) {
        setState(() {
          // 1. Mapeo de Balance Real (Nuevos campos del backend)
          if (balanceData != null) {
            _currentBalance = (balanceData['currentBalance'] as num).toDouble();
            _pendingBalance = (balanceData['pendingBalance'] as num).toDouble();
            _currency = balanceData['currentBalanceCurrency'] ?? "USD";
          }

          // 2. Mapeo de Historial y Gráfico
          if (historyData != null && historyData.monthlyPayouts.isNotEmpty) {
            _history = historyData;
            _chartData = historyData.monthlyPayouts.map((e) => e.amount).toList();
            if (_chartData.length == 1) _chartData.insert(0, 0);

            _chartLabels = historyData.monthlyPayouts.map((e) {
              final parts = e.yearMonth.split('-');
              const months = ['','Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
              return months[int.tryParse(parts[1]) ?? 0];
            }).toList();
            _selectedIndex = _chartData.length - 1;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error en PaymentsScreen: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: _buildBalanceSection(),
                    ),
                    _buildChartContainer(),
                    const SizedBox(height: 32),
                    _buildPayoutsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF6B1FA8), Color(0xFF3D0D6B), Color(0xFF0D0018)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: const Text('Mis Pagos', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ganancias Totales', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(
                accessToken: widget.accessToken,
                initialBalance: _currentBalance,
                pendingBalance: _pendingBalance, // 🚀 Pasamos ambos a la billetera
              ))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
                child: const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 14), SizedBox(width: 7), Text('Mi Billetera', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountText(_currentBalance),
        const SizedBox(height: 12),
        Row(children: [
          _badge('Recibido: \$${_history?.totalAmount.toStringAsFixed(2) ?? "0.00"}', const Color(0xFF06C167)),
          const SizedBox(width: 10),
          _badge('En Proceso: \$${_pendingBalance.toStringAsFixed(2)}', const Color(0xFFFF9500)),
        ]),
      ],
    );
  }

  Widget _buildAmountText(double amount) {
    final intPart = amount.toInt();
    final decPart = ((amount - intPart) * 100).toInt().toString().padLeft(2, '0');
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: -1),
        children: [
          TextSpan(text: '\$ $intPart', style: const TextStyle(fontSize: 46)),
          TextSpan(text: '.$decPart', style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  Widget _buildChartContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rendimiento Mensual", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: GestureDetector(
              onTapDown: (d) => _onChartTap(d.localPosition),
              child: CustomPaint(painter: _AreaChartPainter(data: _chartData, selectedIndex: _selectedIndex, labels: _chartLabels)),
            ),
          ),
        ],
      ),
    );
  }

  void _onChartTap(Offset pos) {
    final chartWidth = MediaQuery.of(context).size.width - 80;
    final step = chartWidth / (_chartData.length - 1);
    setState(() => _selectedIndex = (pos.dx / step).round().clamp(0, _chartData.length - 1));
  }

  Widget _buildPayoutsList() {
    final payouts = _history?.monthlyPayouts ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mis Cobros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (payouts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Aún no realizaste cobros', style: TextStyle(color: Colors.grey))))
          else
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: payouts.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F7)),
              itemBuilder: (context, index) {
                final item = payouts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: const Color(0xFFF2F2F7), child: const Icon(Icons.download_rounded, color: Colors.black, size: 20)),
                  title: Text(_formatDate(item.yearMonth), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('+\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF06C167), fontWeight: FontWeight.bold)),
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatDate(String ym) {
    final parts = ym.split('-');
    const months = ['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return '${months[int.parse(parts[1])]} ${parts[0]}';
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [CircleAvatar(radius: 3, backgroundColor: color), const SizedBox(width: 6), Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))]),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;
  final List<String> labels;

  _AreaChartPainter({required this.data, required this.selectedIndex, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const double bPad = 25;
    const double tPad = 10;
    final cH = size.height - bPad - tPad;
    final cW = size.width;

    double maxVal = data.reduce(max);
    maxVal = maxVal == 0 ? 100 : maxVal * 1.2;

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * cW;
      final y = tPad + cH - (data[i] / maxVal) * cH;
      pts.add(Offset(x, y));
    }

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final m = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final n = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      path.cubicTo(m.dx, m.dy, n.dx, n.dy, pts[i + 1].dx, pts[i + 1].dy);
    }

    final area = Path.from(path)..lineTo(cW, size.height - bPad)..lineTo(0, size.height - bPad)..close();
    canvas.drawPath(area, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.05), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, cW, size.height)));
    canvas.drawPath(path, Paint()..color = Colors.black..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    for (int i = 0; i < labels.length; i++) {
      final x = (i / (data.length - 1)) * cW;
      final tp = TextPainter(text: TextSpan(text: labels[i], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width/2, size.height - bPad + 8));
    }

    if (selectedIndex != null) {
      final p = pts[selectedIndex!];
      canvas.drawCircle(p, 5, Paint()..color = Colors.black);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
      final tp = TextPainter(text: TextSpan(text: '\$${data[selectedIndex!].toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      double tx = p.dx - tp.width/2 - 8;
      tx = tx.clamp(0.0, cW - tp.width - 16);
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(tx, p.dy - 35, tp.width + 16, 26), const Radius.circular(8));
      canvas.drawRRect(rect, Paint()..color = Colors.black);
      tp.paint(canvas, Offset(tx + 8, p.dy - 30));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}