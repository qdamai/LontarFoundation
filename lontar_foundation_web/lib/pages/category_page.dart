import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/category_card.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToProductList(String category) {
      Navigator.pushNamed(context, '/products', arguments: category);
    }

    final List<Map<String, dynamic>> categories = [
      {'name': 'Art', 'icon': Icons.palette_outlined},
      {'name': 'Book', 'icon': Icons.book_outlined},
      {'name': 'Cloth', 'icon': Icons.texture_outlined},
      {'name': 'Other', 'icon': Icons.more_horiz_outlined},
      {'name': 'Wayang', 'icon': Icons.theater_comedy_outlined},
    ];
    categories.sort((a, b) => a['name'].compareTo(b['name']));

    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a category below to view our collection of art, books, and crafts.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              ...categories.map((cat) => Column(
                children: [
                  CategoryCard(
                    categoryName: cat['name'],
                    icon: cat['icon'],
                    onTap: () => navigateToProductList(cat['name'].toLowerCase()),
                  ),
                  const SizedBox(height: 20),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
} 