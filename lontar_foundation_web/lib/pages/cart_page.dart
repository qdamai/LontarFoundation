import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../widgets/custom_app_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text('Your cart is empty', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(32.0),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cart.items.values.toList()[i];
                          return ListTile(
                            leading: item.product.imageUrl.startsWith('http')
                              ? Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : Image.asset(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(item.product.name),
                            subtitle: Text(formatter.format(item.product.price)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('x ${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => cart.removeItem(item.product.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: Theme.of(context).textTheme.headlineMedium),
                          Text(
                            formatter.format(cart.totalAmount),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              child: const Text('Clear All'),
                              onPressed: () => cart.clearCart(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              child: const Text('Checkout'),
                              onPressed: () => Navigator.pushNamed(context, '/checkout'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
} 