import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'creator_profile_screen.dart';

class BirthDateScreen extends StatefulWidget {
  final String accessToken;
  final String email; // <--- AGREGADO: Para pasarlo al perfil final

  const BirthDateScreen({
    super.key,
    required this.accessToken,
    required this.email,
  });

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  final _dateController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDateValid = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- Lógica de Validación de Fecha y Edad ---
  void _validateDate(String value) {
    // El formato con espacios es "DD / MM / AAAA" (14 caracteres)
    if (value.length < 14) {
      if (_isDateValid) setState(() { _isDateValid = false; _errorText = null; });
      return;
    }

    try {
      // Limpiamos los espacios y separamos por '/'
      List<String> parts = value.replaceAll(' ', '').split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      final now = DateTime.now();

      // Validaciones básicas de calendario
      if (year < 1900 || year > now.year || month < 1 || month > 12 || day < 1 || day > 31) {
        throw Exception();
      }

      final dob = DateTime(year, month, day);

      // Cálculo de edad
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      if (age < 18) {
        setState(() {
          _isDateValid = false;
          _errorText = "Debes ser mayor de 18 años para continuar.";
        });
        return;
      }

      // Si todo está bien
      setState(() {
        _isDateValid = true;
        _errorText = null;
      });

    } catch (e) {
      setState(() {
        _isDateValid = false;
        _errorText = "Fecha inválida.";
      });
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                '¿Cuándo es tu cumpleaños?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu edad nos ayuda a mantener segura la comunidad de Inklop.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Campo de entrada de fecha
              TextField(
                controller: _dateController,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  BirthDateInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'DD / MM / AAAA',
                  hintStyle: const TextStyle(color: Color(0xFFE0E0E0)),
                  errorText: _errorText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: _validateDate,
              ),

              const Spacer(),

              // Botón Continuar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isDateValid
                      ? () {
                    // Extraemos partes para formatear a YYYY-MM-DD
                    final parts = _dateController.text.replaceAll(' ', '').split('/');
                    final formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatorProfileScreen(
                          accessToken: widget.accessToken,
                          birthDate: formattedDate,
                          email: widget.email, // <--- SOLUCIÓN AL ERROR
                        ),
                      ),
                    );
                  }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    disabledBackgroundColor: const Color(0xFFF1F1F1),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      color: _isDateValid ? Colors.white : const Color(0xFFADADAD),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Formateador de Texto para la Fecha (DD / MM / AAAA) ---
class BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length && nonZeroIndex <= 4) {
        buffer.write(' / ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}