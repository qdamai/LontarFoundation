import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _waController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _waController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final itemsText = cart.items.values.map((item) =>
      '- ${item.product.name} (x${item.quantity}) | ${item.product.price}').join('\n');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 600,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Checkout', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _waController,
                          decoration: const InputDecoration(labelText: 'WhatsApp Number', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Shipping Address', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        Text('Items:', style: Theme.of(context).textTheme.titleLarge),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(itemsText),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            child: const Text('Checkout via WhatsApp'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final message = Uri.encodeComponent(
                                  'Hello, I would like to purchase the following item(s):\n\n'
                                  'Item(s):\n$itemsText\n\n'
                                  'Buyer Name: ${_nameController.text}\n'
                                  'Contact: ${_emailController.text.isNotEmpty ? _emailController.text : _waController.text}\n'
                                  'WhatsApp: ${_waController.text}\n'
                                  'Address: ${_addressController.text}\n'
                                  'Notes: ${_notesController.text}\n\n'
                                  'Please confirm availability. Thank you!'
                                );
                                final url = 'https://wa.me/6281261928467?text=$message';
                                Provider.of<CartProvider>(context, listen: false).clearCart();
                                // ignore: deprecated_member_use
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  // ignore: deprecated_member_use
                                  // ignore: use_build_context_synchronously
                                  launchUrl(Uri.parse(url));
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 