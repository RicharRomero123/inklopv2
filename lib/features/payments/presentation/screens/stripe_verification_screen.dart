import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/stripe_api_service.dart';
import '../../data/models/stripe_models.dart';

class StripeVerificationScreen extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> userData;

  const StripeVerificationScreen({
    super.key,
    required this.accessToken,
    required this.userData,
  });

  @override
  State<StripeVerificationScreen> createState() => _StripeVerificationScreenState();
}

class _StripeVerificationScreenState extends State<StripeVerificationScreen> {
  final _apiService = StripeApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // --- CONTROLADORES ---
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _bankController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    // Precarga de datos desde /users/me
    _firstNameController = TextEditingController(text: widget.userData['names'] ?? '');
    _lastNameController = TextEditingController(text: widget.userData['lastNames'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phoneNumber'] ?? '');
    _birthDateController = TextEditingController(text: widget.userData['birthDate'] ?? '');
    _cityController = TextEditingController(text: widget.userData['city'] ?? '');

    // Campos manuales
    _bankController = TextEditingController();
    _addressController = TextEditingController();
    _stateController = TextEditingController();
    _postalController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose(); _lastNameController.dispose();
    _emailController.dispose(); _phoneController.dispose();
    _birthDateController.dispose(); _bankController.dispose();
    _addressController.dispose(); _cityController.dispose();
    _stateController.dispose(); _postalController.dispose();
    super.dispose();
  }

  Future<void> _startOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Formateo de teléfono para cumplimiento de Stripe (+51)
    final String rawPhone = _phoneController.text.trim();
    final String formattedPhone = rawPhone.startsWith('+') ? rawPhone : '+51$rawPhone';

    final request = StripeAccountRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: formattedPhone,
      externalBankAccount: _bankController.text.trim(),
      city: _cityController.text.trim(),
      line1: _addressController.text.trim(),
      postalCode: _postalController.text.trim(),
      state: _stateController.text.trim(),
      currency: "PEN", // 🚀 CAMBIO CLAVE: Ahora enviamos PEN para cuentas PE
    );

    try {
      final response = await _apiService.createConnectedAccount(widget.accessToken, request);

      if (response != null) {
        final onboardingUrl = await _apiService.generateAccountLink(widget.accessToken);
        if (onboardingUrl != null && mounted) {
          // 🚀 CAMBIO AQUÍ: Agregamos .url
          await launchUrl(Uri.parse(onboardingUrl.url), mode: LaunchMode.externalApplication);
          if (mounted) Navigator.pop(context);
        }
      }else {
        _showError("Error al procesar la solicitud. Revisa los logs.");
      }
    } catch (e) {
      _showError("Error de conexión: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Vincular con Stripe", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text("Configura tus cobros", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    const Text("Completa tus datos para recibir transferencias bancarias en Soles (PEN).",
                        style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15, height: 1.4)),
                    const SizedBox(height: 32),

                    _sectionHeader("Datos Personales"),
                    Row(
                      children: [
                        Expanded(child: _buildField("Nombres", _firstNameController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField("Apellidos", _lastNameController)),
                      ],
                    ),
                    _buildField("Correo electrónico", _emailController, keyboard: TextInputType.emailAddress),
                    Row(
                      children: [
                        Expanded(child: _buildField("Teléfono", _phoneController, keyboard: TextInputType.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField("Nacimiento (AAAA-MM-DD)", _birthDateController, hint: "2002-04-04")),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionHeader("Cuenta Bancaria"),
                    _buildField("Número de Cuenta o CCI", _bankController, icon: Icons.account_balance_rounded),

                    const SizedBox(height: 24),
                    _sectionHeader("Dirección Fiscal"),
                    _buildField("Dirección", _addressController),
                    Row(
                      children: [
                        Expanded(child: _buildField("Ciudad", _cityController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField("Estado / Prov", _stateController)),
                      ],
                    ),
                    _buildField("Código Postal", _postalController),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // BOTÓN DE ACCIÓN
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _startOnboarding,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF), // Stripe Purple
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Confirmar y continuar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF635BFF), letterSpacing: 1.2)),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboard = TextInputType.text, String? hint, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
              filled: true,
              fillColor: const Color(0xFFF2F2F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF635BFF), width: 1.5)),
            ),
            validator: (v) => v!.isEmpty ? "" : null,
          ),
        ],
      ),
    );
  }
}