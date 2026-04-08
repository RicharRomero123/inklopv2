import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inklop_v1/features/campaigns/presentation/screens/submission_flow_screen.dart';
import 'package:inklop_v1/features/campaigns/presentation/screens/campaign_submissions_screen.dart';
// 🚀 IMPORTANTE: Ajusta esta ruta a tu archivo AiScriptModal
import '../widgets/ai_script_modal.dart';
import '../../data/campaign_api_service.dart';
import '../../data/models/campaign_model.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  final String accessToken;
  const CampaignDetailScreen({super.key, required this.campaign, required this.accessToken});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final _apiService = CampaignApiService();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  bool _isGenerating = false;
  int _selectedTab = 0;
  bool _isBlurred = false;
  double _anchorSize = 0.5;

  bool _isLoadingStatus = true;
  List<dynamic> _mySubmissions = [];

  static const _purpleGradient = LinearGradient(colors: [Color(0xFF2E0B3F), Color(0xFF5E17EB)]);
  static const _bottomGradient = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF2E0B3F), Colors.black], stops: [0.0, 0.7]);
  static const _darkGradient = LinearGradient(colors: [Colors.black, Color(0xFF2C0A40)]);

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    _fetchCampaignStatus();
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaignStatus() async {
    if (!mounted) return;
    setState(() => _isLoadingStatus = true);
    final allSubmissions = await _apiService.getMySubmissions(widget.accessToken);
    if (allSubmissions != null && mounted) {
      setState(() {
        _mySubmissions = allSubmissions.where((s) => s['campaign']?['idCampaign']?.toString() == widget.campaign.id.toString()).toList();
        _isLoadingStatus = false;
      });
    } else {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }


  void _onSheetChanged() {
    if (!mounted) return;
    final bool shouldBlur = _sheetController.size > (_anchorSize + 0.05);
    if (_isBlurred != shouldBlur) setState(() => _isBlurred = shouldBlur);
  }

  // ── 🚀 FUNCIÓN DE GENERACIÓN CORREGIDA ──────────────────────────────────
  void _generateScript() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      // Pasamos el ID de la campaña actual
      final result = await _apiService.getAiScript(widget.campaign.id, widget.accessToken);

      if (!mounted) return;
      setState(() => _isGenerating = false);

      if (result != null && result['script'] != null) {
        // Mostramos tu modal pasándole el string del script
        AiScriptModal.show(context, result['script']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo generar el guión en este momento.")),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isGenerating = false);
      print("Error en UI IA: $e");
    }
  }

  // ── (Mantenemos el resto de modales y helpers igual) ───────────────────
  void _showInstructionsModal() {
    final text = widget.campaign.description;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(height: MediaQuery.of(context).size.height * 0.85, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: Column(children: [const SizedBox(height: 15), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20), Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: _purpleGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description, color: Colors.white, size: 22)), const SizedBox(width: 16), const Text('Instrucciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])), const SizedBox(height: 10), const Divider(), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Text(text, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)))), Container(padding: const EdgeInsets.fromLTRB(24, 10, 24, 40), child: Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => Clipboard.setData(ClipboardData(text: text)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.black), shape: const StadiumBorder()), icon: const Icon(Icons.copy_outlined, color: Colors.black, size: 18), label: const Text('Copiar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))), const SizedBox(width: 16), Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.black, shape: const StadiumBorder()), child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold))))]))])));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.campaign;
    final Size screenSize = MediaQuery.of(context).size;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    const double headerHeight = 260.0;
    const double overlap = 50.0;
    final double topSafeArea = statusBarHeight + 70.0;

    final double maxSheetHeight = (screenSize.height - topSafeArea) / screenSize.height;
    final double initialSheetHeight = (screenSize.height - (headerHeight - overlap)) / screenSize.height;

    final double safeMax = maxSheetHeight.clamp(0.0, 1.0);
    final double safeInitial = initialSheetHeight.clamp(0.0, safeMax);
    _anchorSize = safeInitial;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0018),
      body: Stack(
        children: [
          // Header (Banner)
          Positioned(
            top: 0, left: 0, right: 0, height: headerHeight,
            child: Stack(fit: StackFit.expand, children: [
              ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: Image.network(c.image, fit: BoxFit.cover)),
              Container(color: Colors.black.withOpacity(0.35)),
              Center(child: TweenAnimationBuilder<double>(tween: Tween<double>(begin: 0.0, end: _isBlurred ? 12.0 : 0.0), duration: const Duration(milliseconds: 400), builder: (_, blurVal, child) => ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blurVal, sigmaY: blurVal), child: child!), child: Container(width: 108, height: 108, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(c.businessImage), fit: BoxFit.cover), border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)])))),
              Positioned(bottom: 0, left: 0, right: 0, height: 60, child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF0D0018), Colors.transparent])))),
            ]),
          ),

          // Botón Atrás
          Positioned(top: statusBarHeight + 10, left: 16, child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3))), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16)))),

          // Sheet Principal
          DraggableScrollableSheet(
            controller: _sheetController, initialChildSize: safeInitial, maxChildSize: safeMax, minChildSize: safeInitial,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
                child: SingleChildScrollView(
                  controller: scrollController, padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: Container(margin: const EdgeInsets.only(top: 12, bottom: 20), width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    Text(c.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Row(children: [Text(c.businessName, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)), const SizedBox(width: 5), const Icon(Icons.verified, color: Color(0xFF5E17EB), size: 16)]),
                    const SizedBox(height: 22),
                    _buildInfoRow(c),
                    const SizedBox(height: 22),
                    _buildProgressBar(c),
                    const SizedBox(height: 28),
                    _buildTabs(),
                    const SizedBox(height: 22),
                    _selectedTab == 0 ? _buildInfoTab(c) : _buildResourcesTab(),
                    const SizedBox(height: 130),
                  ]),
                ),
              );
            },
          ),

          // Botón Inferior
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomButton(c)),
        ],
      ),
    );
  }

  // ── WIDGETS AUXILIARES ────────────────────────────────────────────────────

  Widget _buildInfoTab(Campaign c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      const SizedBox(height: 10),
      Text(c.description, style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14)),
      const SizedBox(height: 22),
      Row(children: [Expanded(child: _darkStatCard(title: 'Pago Máximo', amount: '\$${c.budget.maxPayment.toStringAsFixed(2)}', subtitle: '=100K vistas')), const SizedBox(width: 12), Expanded(child: _darkStatCard(title: 'CPM', amount: '\$${c.budget.cpm.toStringAsFixed(2)}', subtitle: '/1K vistas'))]),
      const SizedBox(height: 24),
      _buildAiScriptBanner(), // 🚀 NUEVO BANNER CON LÓGICA MEJORADA
      const SizedBox(height: 24),
    ]);
  }

  // 🚀 BANNER DE IA CON ÁREA DE TOQUE BLINDADA
  Widget _buildAiScriptBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6F3)),
      ),
      child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Guiones Inteligentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Crea guiones impactantes con IA', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        // BOTÓN ACCIONABLE
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isGenerating ? null : _generateScript,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(gradient: _purpleGradient, borderRadius: BorderRadius.circular(12)),
              child: _isGenerating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('Generar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // (Demás widgets _buildInfoRow, _detailBox, _buildProgressBar, _buildTabs, _buildTabBtn, _darkStatCard, _buildResourcesTab, _resourceBtn, _buildBottomButton, _joinButton, _actionButtons, _goToFlow se mantienen como en la versión anterior)

  Widget _buildInfoRow(Campaign c) { return Row(children: [Expanded(child: _detailBox(label: 'Tipo', child: Text(c.creatorType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis))), const SizedBox(width: 10), Expanded(child: _detailBox(label: 'Plataformas', child: Row(children: [if(c.allowsTiktok) Image.asset('assets/images/ic_tiktok.png', width: 17), if(c.allowsInstagram) ...[const SizedBox(width: 5), Image.asset('assets/images/ic_instagram.png', width: 17)]]))), const SizedBox(width: 10), Expanded(child: _detailBox(label: 'Fecha Límite', child: Text("En desarrollo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)))] ); }
  Widget _detailBox({required String label, required Widget child}) { return Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200, width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500)), const SizedBox(height: 5), child])); }
  Widget _buildProgressBar(Campaign c) { final double progress = (c.budget.percentage / 100).clamp(0.0, 1.0); return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.grey.shade200, width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progreso de Campaña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('${c.budget.percentage.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]), const SizedBox(height: 12), LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFEEEEEE), color: const Color(0xFF5E17EB), minHeight: 10, borderRadius: BorderRadius.circular(10)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$${c.budget.spent.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('de \$${c.budget.total.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600], fontSize: 12))])])); }
  Widget _buildTabs() { return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildTabBtn('Información', 0), const SizedBox(width: 40), _buildTabBtn('Recursos', 1)]); }
  Widget _buildTabBtn(String text, int index) { final bool sel = _selectedTab == index; return GestureDetector(onTap: () => setState(() => _selectedTab = index), child: Column(children: [Text(text, style: TextStyle(fontSize: 16, fontWeight: sel ? FontWeight.w800 : FontWeight.w500, color: sel ? Colors.black : Colors.grey[500])), const SizedBox(height: 5), AnimatedContainer(duration: const Duration(milliseconds: 250), height: 3, width: sel ? 48 : 0, decoration: BoxDecoration(gradient: _purpleGradient, borderRadius: BorderRadius.circular(2)))])); }
  Widget _darkStatCard({required String title, required String amount, required String subtitle}) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: _darkGradient), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 8), Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 11))])); }
  Widget _buildResourcesTab() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_resourceBtn(icon: Icons.description_outlined, title: 'Instrucciones de Contenido', onTap: _showInstructionsModal), const SizedBox(height: 12), _resourceBtn(icon: Icons. camera_alt_outlined, title: 'Instagram de la marca', onTap: () {})]); }
  Widget _resourceBtn({required IconData icon, required String title, required VoidCallback onTap}) { return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: _darkGradient, borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: Colors.white, size: 22), const SizedBox(width: 14), Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)), const Spacer(), const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14)]))); }
  Widget _buildBottomButton(Campaign c) { return Container(padding: const EdgeInsets.fromLTRB(24, 20, 24, 36), decoration: BoxDecoration(gradient: _bottomGradient, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))), child: _isLoadingStatus ? const Center(child: CircularProgressIndicator(color: Colors.white)) : _mySubmissions.isEmpty ? _joinButton(c) : _actionButtons(c)); }
  Widget _joinButton(Campaign c) { return SizedBox(height: 54, width: double.infinity, child: ElevatedButton(onPressed: () => _goToFlow(c), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()), child: const Text('Unirme a la Campaña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))); }
  Widget _actionButtons(Campaign c) { return Row(children: [Expanded(child: OutlinedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignSubmissionsScreen(submissions: _mySubmissions, campaignTitle: c.title))); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 1.5), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Mis Envíos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () => _goToFlow(c), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Enviar Video', style: TextStyle(fontWeight: FontWeight.bold))))]); }
  void _goToFlow(Campaign c) { Navigator.push(context, MaterialPageRoute(builder: (_) => SubmissionFlowScreen(campaign: c, accessToken: widget.accessToken))).then((_) => _fetchCampaignStatus()); }
}