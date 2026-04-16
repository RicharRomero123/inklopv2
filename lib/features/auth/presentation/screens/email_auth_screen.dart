import 'package:flutter/material.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/auth_service.dart';
import '../../data/user_api_service.dart';
import 'birth_date_screen.dart';
import '../../../main/presentation/main_screen.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final AuthService _authService = AuthService();
  final UserApiService _userApiService = UserApiService();
  final SecureStorageService _storageService = SecureStorageService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isCheckingPassword = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 12;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _canContinue {
    if (!_isCheckingPassword) {
      return _emailController.text.contains('@');
    } else {
      return _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar;
    }
  }

  void _showVerificationDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Revisa tu correo! 📩', textAlign: TextAlign.center),
        content: const Text(
          'Te enviamos un enlace de verificación. Ábrelo desde tu celular o computadora. Cuando lo hayas hecho, presiona el botón de abajo.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _submit();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ya verifiqué mi correo', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _passwordController.clear());
            },
            child: const Text('Lo haré más tarde', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ... (imports se mantienen igual)

  // ── LÓGICA DE SUBMIT (FORZANDO STRINGS) ───────────────────────────────────
  Future<void> _submit() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) return;
    if (password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 🚀 FORZAMOS LA DECLARACIÓN COMO STRING
      String? accessToken;
      String? refreshToken;

      try {
        final dynamic result = await _authService.loginWithEmail(email, password);

        // 🚀 FORZAMOS LA CONVERSIÓN A STRING CON .toString()
        accessToken = result['token']?.toString();
        refreshToken = result['refreshToken']?.toString();

      } catch (loginError) {
        try {
          await _authService.signUpWithEmail(email, password);
          setState(() => _isLoading = false);
          _showVerificationDialog();
          return;
        } catch (signUpError) {
          final errorStr = signUpError.toString().toLowerCase();
          if (errorStr.contains('user already exists')) {
            throw Exception('La contraseña es incorrecta.');
          } else {
            throw Exception(signUpError.toString().replaceAll('Exception:', '').trim());
          }
        }
      }

      // Si llegamos aquí y el token no es nulo, procedemos
      if (accessToken != null && mounted) {
        final bool isCompleted = await _userApiService.isProfileCompleted(accessToken);

        if (isCompleted) {
          // ✅ Usamos el nuevo método saveToken con parámetros nombrados
          await _storageService.saveToken(
            access: accessToken,
            refresh: refreshToken ?? '',
          );

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                // 🚩 SI ESTA LÍNEA DA ERROR: Ve a main_screen.dart y cambia 'int' por 'String'
                builder: (_) => MainScreen(accessToken: accessToken!),
              ),
                  (route) => false,
            );
          }
        } else {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                // 🚩 SI ESTA LÍNEA DA ERROR: Ve a birth_date_screen.dart y cambia 'int' por 'String'
                builder: (_) => BirthDateScreen(accessToken: accessToken!, email: email),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

// ... (resto del widget se mantiene igual)

  void _onContinue() {
    if (!_isCheckingPassword) {
      setState(() => _isCheckingPassword = true);
    } else {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            if (_isCheckingPassword) {
              setState(() {
                _isCheckingPassword = false;
                _passwordController.clear();
                _hasMinLength = _hasUppercase = _hasNumber = _hasSpecialChar = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 64, width: 64,
                  decoration: const BoxDecoration(color: Color(0xFFF8F8F8), shape: BoxShape.circle),
                  child: Center(
                    child: Image.asset('assets/images/icon_email_header.png', height: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isCheckingPassword ? 'Ingresar con Email' : 'Continuar con Email',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                hint: 'Dirección de Email',
                enabled: !_isCheckingPassword,
                suffix: _isCheckingPassword
                    ? TextButton(
                  onPressed: () => setState(() => _isCheckingPassword = false),
                  child: const Text('Editar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                )
                    : null,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              if (_isCheckingPassword) ...[
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hint: 'Ingresa tu Contraseña',
                  obscureText: !_isPasswordVisible,
                  onChanged: _validatePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tu contraseña debe contener', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildValidatorRow('Al menos 12 caracteres', _hasMinLength),
                      _buildValidatorRow('Al menos 1 mayúscula', _hasUppercase),
                      _buildValidatorRow('Al menos 1 número', _hasNumber),
                      _buildValidatorRow('Al menos 1 caracter especial', _hasSpecialChar),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: (_canContinue && !_isLoading) ? _onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: const StadiumBorder(),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    Widget? suffix,
    bool obscureText = false,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    final bool isActive = focusNode.hasFocus || controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isActive ? const Color(0xFFE0E0E0) : const Color(0xFFF0F0F0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFADADAD), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _buildValidatorRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(isValid ? Icons.check : Icons.close, color: isValid ? Colors.green : Colors.red, size: 14),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: isValid ? Colors.green : Colors.red, fontSize: 13)),
        ],
      ),
    );
  }
}