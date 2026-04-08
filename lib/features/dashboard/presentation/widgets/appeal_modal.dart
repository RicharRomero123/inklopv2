import 'package:flutter/material.dart';

class AppealModal extends StatefulWidget {
  final int submissionId;
  final Function(String reason) onSend;

  const AppealModal({super.key, required this.submissionId, required this.onSend});

  static void show(BuildContext context, int submissionId, Function(String) onSend) {
    showDialog(
      context: context,
      builder: (context) => AppealModal(submissionId: submissionId, onSend: onSend),
    );
  }

  @override
  State<AppealModal> createState() => _AppealModalState();
}

class _AppealModalState extends State<AppealModal> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🚩 Icono de Bandera
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE57373), shape: BoxShape.circle),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text("Apelar Decisión", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Explica por qué consideras que tu video si cumple con el brief y pautas",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            // Input de motivo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Motivo de tu apelación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe detalladamente por qué tu video cumple con todos los requisitos de contenido",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 20),
            // Cuadro de advertencia rojo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(15)),
              child: const Text.rich(
                TextSpan(
                    children: [
                      TextSpan(text: "Importante: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      TextSpan(text: "Solo puedes apelar 1 vez. Asegúrate de incluir todos los detalles relevantes", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ]
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botón enviar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : () async {
                  if (_reasonController.text.isNotEmpty) {
                    setState(() => _isSending = true);
                    await widget.onSend(_reasonController.text);
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: _isSending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: const Text("Enviar Apelación", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}