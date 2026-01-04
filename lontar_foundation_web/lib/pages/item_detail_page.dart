import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_provider.dart';
import '../widgets/custom_app_bar.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments;
    if (product == null || product is! Product) {
      return Scaffold(
        appBar: const CustomAppBar(),
        body: const Center(child: Text('No product data found.')),
      );
    }
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: isDesktop 
                ? _buildDesktopLayout(context, product, textTheme, colorScheme, formatter)
                : _buildMobileLayout(context, product, textTheme, colorScheme, formatter),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Product product, TextTheme textTheme, ColorScheme colorScheme, NumberFormat formatter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Hero(
            tag: product.id,
            child: product.imageUrl.startsWith('http')
              ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
              : Image.asset(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 3,
          child: _buildProductDetails(context, product, textTheme, colorScheme, formatter),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, Product product, TextTheme textTheme, ColorScheme colorScheme, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: product.id,
          child: product.imageUrl.startsWith('http')
            ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
            : Image.asset(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
        ),
        const SizedBox(height: 24),
        _buildProductDetails(context, product, textTheme, colorScheme, formatter),
      ],
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product, TextTheme textTheme, ColorScheme colorScheme, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(product.name, style: textTheme.displayLarge?.copyWith(fontSize: 36)),
        const SizedBox(height: 24),
        Text(
          formatter.format(product.price),
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        Text(product.description ?? '', style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        if (product.details.isNotEmpty) ...[
          ...product.details.entries.where((e) => e.key != 'name' && e.key != 'image_url' && e.value.isNotEmpty).map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: '${_formatDetailKey(entry.key)}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: entry.value),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add to Cart'),
            onPressed: () {
              final cart = Provider.of<CartProvider>(context, listen: false);
              cart.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} telah ditambahkan ke keranjang.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDetailKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
} 