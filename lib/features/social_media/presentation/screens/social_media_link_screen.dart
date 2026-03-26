import 'package:flutter/material.dart';
import 'package:inklop_v1/features/main/presentation/main_screen.dart';
import 'package:inklop_v1/features/social_media/data/models/social_media_model.dart';
import 'package:inklop_v1/features/social_media/data/social_media_api_service.dart';
import '../widgets/url_input_modal.dart';
import '../widgets/verification_modal.dart';

class SocialMediaLinkScreen extends StatefulWidget {
  final String accessToken;
  const SocialMediaLinkScreen({super.key, required this.accessToken});

  @override
  State<SocialMediaLinkScreen> createState() => _SocialMediaLinkScreenState();
}

class _SocialMediaLinkScreenState extends State<SocialMediaLinkScreen> {
  final _apiService = SocialMediaApiService();
  List<SocialMediaAccount> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() => _isLoading = true);
    final list = await _apiService.getMySocialMedias(widget.accessToken);
    setState(() {
      _accounts = list;
      _isLoading = false;
    });
  }

  void _openUrlModal(String platform) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => UrlInputModal(
        platform: platform,
        onConfirm: (url) async {
          Navigator.pop(context);
          final newAcc = await _apiService.linkAccount(platform, url, widget.accessToken);
          if (newAcc != null) {
            _fetchAccounts();
            _openVerificationModal(newAcc);
          }
        },
      ),
    );
  }

  void _openVerificationModal(SocialMediaAccount account) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => VerificationModal(
        account: account,
        onVerify: () async {
          final success = await _apiService.verifyAccount(account.id, widget.accessToken);
          if (success && mounted) {
            Navigator.pop(context);
            _fetchAccounts();
            return true;
          }
          return false;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canContinue = _accounts.any((a) => a.isVerified);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Icon(Icons.travel_explore, size: 48),
            const SizedBox(height: 16),
            const Text('Vincula tu redes sociales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Conecta tu Tiktok e Instagram para comenzar', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView(
                  children: [
                    ..._accounts.map((acc) => _buildAccountItem(acc)),
                    const SizedBox(height: 8),
                    _buildConnectBtn('TikTok'),
                    const SizedBox(height: 12),
                    _buildConnectBtn('Instagram'),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity, height: 56,
              child: FilledButton(
                onPressed: canContinue
                    ? () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreen(accessToken: widget.accessToken) // 🚀 CORREGIDO: widget.accessToken y sin const
                    )
                )
                    : null,
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[200]
                ),
                child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(SocialMediaAccount acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(acc.platform == 'TIKTOK' ? Icons.music_note : Icons.camera_alt),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(acc.displayUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(acc.isVerified ? 'Verificado' : 'Pendiente', style: TextStyle(color: acc.isVerified ? Colors.green : Colors.orange, fontSize: 12)),
          ]),
          const Spacer(),
          if (!acc.isVerified) IconButton(icon: const Icon(Icons.verified_user_outlined), onPressed: () => _openVerificationModal(acc)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async {
            if (await _apiService.deleteAccount(acc.id, widget.accessToken)) _fetchAccounts();
          }),
        ],
      ),
    );
  }

  Widget _buildConnectBtn(String platform) {
    return InkWell(
      onTap: () => _openUrlModal(platform.toUpperCase()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          Text(platform, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text('Conectar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}