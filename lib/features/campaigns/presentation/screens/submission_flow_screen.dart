import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/campaign_api_service.dart';
import '../../data/models/campaign_model.dart';
import '../widgets/social_account_selector.dart';
import '../widgets/video_grid_selector.dart';
import 'submission_success_screen.dart';

class SubmissionFlowScreen extends StatefulWidget {
  final Campaign campaign;
  final String accessToken;
  const SubmissionFlowScreen(
      {super.key, required this.campaign, required this.accessToken});

  @override
  State<SubmissionFlowScreen> createState() => _SubmissionFlowScreenState();
}

class _SubmissionFlowScreenState extends State<SubmissionFlowScreen> {
  final _apiService = CampaignApiService();

  List<dynamic> _allAccounts = [];
  bool _isLoadingAccounts = true;
  bool _isSubmitting = false;

  // ─── Cache en memoria: accountId → videos ────────────────────────────────
  final Map<int, List<SocialVideo>> _memoryCache = {};

  // ─── Set de cuentas siendo fetched actualmente ────────────────────────────
  // Permite fetches paralelos por cuenta sin bloquearse entre tabs.
  final Set<int> _fetchingAccountIds = {};

  String _selectedPlatform = 'TIKTOK';
  int? _selectedAccountId;
  String? _selectedVideoUrl;

  @override
  void initState() {
    super.initState();
    _loadInitialAccounts();
  }

  // ─── PERSISTENCIA EN DISCO ────────────────────────────────────────────────

  Future<void> _saveToDisk(int accountId, List<SocialVideo> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(videos.map((v) => v.toJson()).toList());
      await prefs.setString('cache_videos_$accountId', encoded);
    } catch (e) {
      debugPrint('⚠️ Error guardando en disco: $e');
    }
  }

  Future<List<SocialVideo>> _loadFromDisk(int accountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cache_videos_$accountId');
      if (data != null) {
        final decoded = jsonDecode(data) as List<dynamic>;
        return decoded.map((v) => SocialVideo.fromJson(v)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error leyendo disco: $e');
    }
    return [];
  }

  // ─── CARGA INICIAL ────────────────────────────────────────────────────────

  Future<void> _loadInitialAccounts() async {
    final accounts = await _apiService.getVerifiedAccounts(widget.accessToken);
    if (!mounted) return;
    setState(() {
      _allAccounts = accounts;
      _isLoadingAccounts = false;
    });
    await _autoSelectFirstAccount();
  }

  Future<void> _autoSelectFirstAccount() async {
    final filtered = _allAccounts
        .where((a) => a['platform'] == _selectedPlatform)
        .toList();
    if (filtered.isEmpty) return;

    final int id = filtered.first['id'];
    if (!mounted) return;
    setState(() => _selectedAccountId = id);

    // Cargar desde disco si no hay en memoria
    if (!_memoryCache.containsKey(id)) {
      final diskVideos = await _loadFromDisk(id);
      if (diskVideos.isNotEmpty && mounted) {
        setState(() => _memoryCache[id] = diskVideos);
      }
    }
  }

  // ─── FETCH CON PROTECCIÓN ANTI RACE CONDITION ─────────────────────────────
  //
  // PROBLEMA ORIGINAL: el fetch tardaba 15-40s. Si el usuario cambiaba de tab
  // durante ese tiempo, _selectedAccountId cambiaba. Al llegar la respuesta,
  // el setState guardaba los videos en la cuenta equivocada (la nueva tab).
  //
  // SOLUCIÓN: capturamos `accountId` en una variable LOCAL al inicio del fetch.
  // Al terminar, siempre guardamos en _memoryCache[accountId] (el original),
  // nunca en _selectedAccountId (que pudo cambiar). La UI simplemente lee
  // _memoryCache[_selectedAccountId] — cada tab muestra sus propios datos.

  Future<void> _fetchVideosForAccount(int accountId) async {
    // Evitar fetch duplicado para la misma cuenta
    if (_fetchingAccountIds.contains(accountId)) return;

    if (mounted) setState(() => _fetchingAccountIds.add(accountId));

    const int maxRetries = 3;
    List<SocialVideo> videos = [];

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      if (!mounted) return;
      if (attempt > 1) await Future.delayed(const Duration(seconds: 5));

      try {
        videos = await _apiService.getProfileVideos(
            widget.accessToken, accountId);
        if (videos.isNotEmpty) break;
      } catch (e) {
        debugPrint('❌ Intento $attempt para cuenta $accountId: $e');
      }
    }

    if (!mounted) return;

    if (videos.isNotEmpty) {
      // ✅ Guardamos siempre en el accountId original (no en _selectedAccountId)
      // Esto es lo que previene el bug: aunque el usuario haya cambiado de tab,
      // los videos van a su cuenta correcta en la caché.
      _memoryCache[accountId] = videos;
      await _saveToDisk(accountId, videos);
    }

    if (mounted) setState(() => _fetchingAccountIds.remove(accountId));
  }

  // ─── CAMBIO DE PLATAFORMA ─────────────────────────────────────────────────

  Future<void> _onPlatformChanged(String platform) async {
    setState(() {
      _selectedPlatform = platform;
      _selectedAccountId = null;
      _selectedVideoUrl = null;
    });
    await _autoSelectFirstAccount();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredAccounts = _allAccounts
        .where((a) => a['platform'] == _selectedPlatform)
        .toList();

    final List<SocialVideo> currentVideos = _selectedAccountId != null
        ? (_memoryCache[_selectedAccountId!] ?? <SocialVideo>[])
        : <SocialVideo>[];

    // ¿Está cargando la cuenta actualmente visible?
    final bool isFetchingCurrent = _selectedAccountId != null &&
        _fetchingAccountIds.contains(_selectedAccountId);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/ic_back_arrow.png',
                  width: 12,
                  height: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Enviar Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        titleSpacing: 8,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _sectionTitle('Selecciona una red social'),
                  const SizedBox(height: 12),
                  _buildPlatformSwitcher(),
                  const SizedBox(height: 32),
                  _sectionTitle('Seleccionar Cuenta'),
                  const SizedBox(height: 16),
                  _isLoadingAccounts
                      ? const Center(
                      child:
                      CircularProgressIndicator(color: Colors.white))
                      : SocialAccountSelector(
                    accounts: filteredAccounts,
                    selectedId: _selectedAccountId,
                    onSelect: (id) async {
                      setState(() {
                        _selectedAccountId = id;
                        _selectedVideoUrl = null;
                      });
                      if (!_memoryCache.containsKey(id)) {
                        final disk = await _loadFromDisk(id);
                        if (disk.isNotEmpty && mounted) {
                          setState(() => _memoryCache[id] = disk);
                        }
                      }
                    },
                    onAddAccount: () {},
                  ),
                  const SizedBox(height: 32),
                  _buildVideoSectionHeader(currentVideos, isFetchingCurrent),
                  const SizedBox(height: 16),
                  _buildVideoArea(currentVideos, isFetchingCurrent),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ─── VIDEO SECTION ────────────────────────────────────────────────────────

  Widget _buildVideoSectionHeader(
      List<SocialVideo> videos, bool isFetchingCurrent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle('Seleccionar Video'),
        if (videos.isNotEmpty && !isFetchingCurrent)
          Tooltip(
            message: 'Actualizar videos',
            child: IconButton(
              onPressed: _selectedAccountId == null
                  ? null
                  : () => _fetchVideosForAccount(_selectedAccountId!),
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
            ),
          ),
        // Spinner pequeño en header cuando refresca con caché ya visible
        if (isFetchingCurrent && videos.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white38, strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoArea(List<SocialVideo> videos, bool isFetchingCurrent) {
    // Primera carga sin caché → loader grande
    if (isFetchingCurrent && videos.isEmpty) {
      return _buildScraperLoadingState();
    }

    // Sin videos y sin carga → botón para buscar
    if (videos.isEmpty) {
      return _buildEmptyState();
    }

    // Hay videos → grid (si refresca, el header muestra spinner pequeño)
    return VideoGridSelector(
      videos: videos,
      selectedUrl: _selectedVideoUrl,
      onVideoSelect: (url) => setState(() => _selectedVideoUrl = url),
    );
  }

  Widget _buildScraperLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
          SizedBox(height: 20),
          Text(
            'Buscando tus videos recientes...\nEsto puede tardar unos segundos',
            textAlign: TextAlign.center,
            style:
            TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            'Puedes cambiar de tab mientras carga',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _selectedAccountId == null
            ? null
            : () => _fetchVideosForAccount(_selectedAccountId!),
        icon: const Icon(Icons.search),
        label: const Text('Buscar videos recientes'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          shape: const StadiumBorder(),
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  // ─── PLATFORM SWITCHER ────────────────────────────────────────────────────

  Widget _buildPlatformSwitcher() {
    return Row(
      children: [
        _platformBtn('Tiktok', 'TIKTOK'),
        const SizedBox(width: 12),
        _platformBtn('Instagram', 'INSTAGRAM'),
      ],
    );
  }

  Widget _platformBtn(String label, String platform) {
    final bool isSel = _selectedPlatform == platform;

    // Punto indicador si esta plataforma está cargando en background
    final bool platformLoading = _allAccounts
        .where((a) => a['platform'] == platform)
        .any((a) => _fetchingAccountIds.contains(a['id'] as int));

    return GestureDetector(
      onTap: () => _onPlatformChanged(platform),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Puntito animado si carga en background (tab no activa)
            if (platformLoading && !isSel) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold),
  );

  Widget _buildBottomButton() {
    final bool canSubmit = _selectedVideoUrl != null && !_isSubmitting;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: canSubmit ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: canSubmit ? Colors.white : Colors.white10,
            foregroundColor: Colors.black,
            shape: const StadiumBorder(),
          ),
          child: _isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.black, strokeWidth: 2),
          )
              : const Text('Enviar Video',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ─── SUBMIT ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await _apiService.submitToCampaign(
        widget.accessToken,
        campaignId: widget.campaign.id,
        socialMediaId: _selectedAccountId!,
        videoUrl: _selectedVideoUrl!,
      );
      if (result != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SubmissionSuccessScreen(
                campaignTitle: widget.campaign.title),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(e.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }
}