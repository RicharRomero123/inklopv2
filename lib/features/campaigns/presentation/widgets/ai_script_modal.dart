import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiScriptModal extends StatelessWidget {
  final String script;

  const AiScriptModal({super.key, required this.script});

  // Función estática para llamar al modal fácilmente
  static void show(BuildContext context, String script) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => AiScriptModal(script: script),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Indicador de arrastre
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.auto_awesome, size: 40, color: Color(0xFF9C27B0)),
            const SizedBox(height: 10),
            const Text(
              '¡Guión generado!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Área de contenido Markdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Markdown(
                  controller: scrollController,
                  data: script,
                  styleSheet: MarkdownStyleSheet(
                    h3: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                    p: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF333333)),
                    listBullet: const TextStyle(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Cerrar', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: script));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Guión copiado al portapapeles!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}