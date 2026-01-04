import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryCard({
    required this.categoryName,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFFFFF8F0), // krem hangat
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFB5835A), width: 2), // border coklat emas
      ),
      shadowColor: const Color(0xFFB5835A).withAlpha((0.15 * 255).toInt()),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        hoverColor: const Color(0xFFB5835A).withAlpha((0.08 * 255).toInt()),
        child: Stack(
          children: [
            // Ornamen pojok kiri atas (emoji/motif unicode jika tidak ada asset)
            Positioned(
              top: 10,
              left: 16,
              child: Text('✦', style: TextStyle(fontSize: 22, color: Color(0xFFB5835A), fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8E1C1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB5835A).withAlpha((0.08 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, size: 36, color: const Color(0xFFA44200)),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: const Color(0xFFA44200),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Eksplor koleksi ${categoryName.toLowerCase()}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D4C41)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: const Color(0xFFB5835A)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 