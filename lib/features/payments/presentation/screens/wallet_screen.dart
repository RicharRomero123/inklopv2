// lib/features/payments/presentation/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/stripe_api_service.dart';
import '../../data/models/stripe_models.dart';
import 'stripe_verification_screen.dart';
import '../../../profile/data/profile_api_service.dart';

class WalletScreen extends StatefulWidget {
  final String accessToken;
  final double initialBalance;
  const WalletScreen(
      {super.key, required this.accessToken, required this.initialBalance});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _stripeApi = StripeApiService();
  final _profileApi = ProfileApiService();

  bool _isVerifying = false;
  bool _isLoadingStatus = true;   // cargando el profile-status al entrar
  bool _stripeCompleted = false;  // resultado de completed del endpoint

  StripeAccountLinkResponse? _activeLink;

  @override
  void initState() {
    super.initState();
    _loadStripeStatus();
  }

  // Consulta el estado de Stripe al abrir la pantalla
  Future<void> _loadStripeStatus() async {
    setState(() => _isLoadingStatus = true);
    final status = await _stripeApi.getProfileStatus(widget.accessToken);
    if (mounted) {
      setState(() {
        _stripeCompleted = status?.completed ?? false;
        _isLoadingStatus = false;
      });
    }
  }

  String _getTimeLeft(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return "Expirado";
    return "${diff.inMinutes} min restantes";
  }

  Future<void> _handleIdentityVerification() async {
    setState(() => _isVerifying = true);

    final linkData =
    await _stripeApi.generateAccountLink(widget.accessToken);

    if (linkData != null) {
      setState(() => _activeLink = linkData);
      final uri = Uri.parse(linkData.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text("No se pudo generar el link de verificación")),
        );
      }
    }

    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Mi Billetera",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Balance Total",
                style:
                TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "S/${widget.initialBalance.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 40),

            // Botón verificar identidad (independiente de Stripe)
            Column(
              children: [
                _buildActionBtn(
                  _isVerifying
                      ? "Generando link..."
                      : "Verifica tu Identidad",
                  _isVerifying ? null : _handleIdentityVerification,
                  Colors.white.withOpacity(0.1),
                  showLoading: _isVerifying,
                ),
                if (_activeLink != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Link activo: ${_getTimeLeft(_activeLink!.expiresAt)}",
                      style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Card de Stripe: muestra loader → luego conectada o botón conectar
            _buildStripeCard(),

            const Spacer(),
            const Text("Mis Retiros",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Opacity(
              opacity: 0.5,
              child: Text("No se Realizaron Retiros",
                  style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03)
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: const Color(0xFF635BFF),
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text("S",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título cambia según el estado
                    Text(
                      _isLoadingStatus
                          ? "Verificando cuenta..."
                          : _stripeCompleted
                          ? "Cuenta Stripe conectada"
                          : "Vincula una cuenta de Stripe",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingStatus
                          ? "Un momento por favor"
                          : _stripeCompleted
                          ? "Tu cuenta está activa y lista para recibir pagos"
                          : "Necesitas vincular y verificar tu cuenta para comenzar a recibir pagos",
                      style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Loading / Cuenta conectada / Botón conectar
          if (_isLoadingStatus)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Colors.white54, strokeWidth: 2),
            )
          else if (_stripeCompleted)
            _buildConnectedBadge()
          else
            _buildActionBtn(
              "Conectar Ahora",
                  () async {
                final userData = await _profileApi
                    .getMyProfile(widget.accessToken);
                if (userData != null && mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StripeVerificationScreen(
                        accessToken: widget.accessToken,
                        userData: userData,
                      ),
                    ),
                  );
                  // Al volver de la pantalla de verificación, refrescar el estado
                  _loadStripeStatus();
                }
              },
              Colors.transparent,
              isOutlined: true,
            ),
        ],
      ),
    );
  }

  /// Badge verde que reemplaza el botón cuando la cuenta ya está conectada
  Widget _buildConnectedBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              color: Color(0xFF2ECC71), size: 18),
          SizedBox(width: 8),
          Text(
            "Cuenta conectada correctamente",
            style: TextStyle(
              color: Color(0xFF2ECC71),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
      String label,
      VoidCallback? onTap,
      Color color, {
        bool isOutlined = false,
        bool showLoading = false,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          shape: const StadiumBorder(),
          side: isOutlined
              ? const BorderSide(color: Colors.white24, width: 1.5)
              : BorderSide.none,
        ),
        child: showLoading
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
    );
  }
}