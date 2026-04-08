import 'package:flutter/material.dart';

class SocialAccountSelector extends StatelessWidget {
  final List<dynamic> accounts;
  final int? selectedId;
  final Function(int) onSelect;
  final VoidCallback onAddAccount; // ✅ Agregado de nuevo

  const SocialAccountSelector({
    super.key,
    required this.accounts,
    required this.selectedId,
    required this.onSelect,
    required this.onAddAccount, // ✅ Agregado de nuevo
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1,
        itemBuilder: (context, index) {
          if (index == accounts.length) return _buildAddBtn();

          final acc = accounts[index];
          final isSel = selectedId == acc['id'];
          return GestureDetector(
            onTap: () => onSelect(acc['id']),
            child: Container(
              width: 80, margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: isSel ? Colors.white : Colors.white12, width: 2),
                borderRadius: BorderRadius.circular(15),
                color: isSel ? Colors.white.withOpacity(0.1) : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 24, backgroundImage: NetworkImage(acc['avatar'] ?? '')),
                  const SizedBox(height: 6),
                  Text(acc['nickname'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddBtn() {
    return GestureDetector(
      onTap: onAddAccount,
      child: Container(
        width: 80,
        decoration: BoxDecoration(border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}