import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double total;
  final double percentage;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'USD ${spent.toStringAsFixed(2)} pagados',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey), // Color gris para "de" y "presupuesto"
                children: [
                  const TextSpan(text: 'de '),
                  TextSpan(
                    text: 'USD ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // <-- Esto hace que el monto resalte en negro
                    ),
                  ),
                  const TextSpan(text: ' presupuesto'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[100],
            color: const Color(0xFF9C27B0), // Color morado de tu diseño
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}