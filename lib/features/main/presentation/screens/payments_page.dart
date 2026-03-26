import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mis Pagos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Balance (Estilo Premium)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F0533), Color(0xFF0D0214)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1F0533).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Disponible', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('S/ 1,250.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: StadiumBorder(),
                        ),
                        child: const Text('Retirar dinero'),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text('Transacciones recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Lista de transacciones
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF7F7F7),
                    child: Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                  ),
                  title: const Text('Campaña Topitop', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('24 de Marzo, 2026'),
                  trailing: const Text('+ S/ 150.00', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}