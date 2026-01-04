import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _NavButton(text: 'Home', routeName: '/'),
          SizedBox(width: 20),
          _NavButton(text: 'Categories', routeName: '/category'),
          SizedBox(width: 20),
          _NavButton(text: 'Contact Us', routeName: '/contact'),
        ],
      ),
      actions: <Widget>[
        _CartIconButton(),
        const SizedBox(width: 20),
      ],
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased AppBar height
}

class _CartIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
        if (cartCount > 0)
          Positioned(
            right: 6,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavButton extends StatefulWidget {
  final String text;
  final String routeName;

  const _NavButton({
    required this.text,
    required this.routeName,
  });

  @override
  __NavButtonState createState() => __NavButtonState();
}

class __NavButtonState extends State<_NavButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = const Color(0xFF3B2F2F);
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, widget.routeName),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Stack(
            children: [
              Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _isHovering ? hoverColor : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  color: _isHovering ? hoverColor : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 