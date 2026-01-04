import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Jika kategori book, tampilkan landscape
    if (widget.product.category.toLowerCase() == 'book') {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/item', arguments: widget.product);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ] : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 160,
                  margin: const EdgeInsets.all(16),
                  child: Hero(
                    tag: widget.product.id,
                    child: widget.product.imageUrl.startsWith('http')
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 160,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 160,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.category[0].toUpperCase() + widget.product.category.substring(1),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.product.name, style: textTheme.titleLarge?.copyWith(fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        if (widget.product.description != null && widget.product.description!.isNotEmpty)
                          Text(widget.product.description!, style: textTheme.bodyMedium, maxLines: 5, overflow: TextOverflow.ellipsis),
                        if (widget.product.details['author'] != null && widget.product.details['author']!.isNotEmpty)
                          Text('Author: ${widget.product.details['author']}', style: textTheme.bodyMedium),
                        if (widget.product.details['code'] != null && widget.product.details['code']!.isNotEmpty)
                          Text('Code: ${widget.product.details['code']}', style: textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Text(
                          formatter.format(widget.product.price),
                          style: textTheme.headlineMedium?.copyWith(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color: colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _ImageZoomDialog(product: widget.product),
                                  );
                                },
                                child: const Text('View Detail'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  final cart = Provider.of<CartProvider>(context, listen: false);
                                  cart.addItem(widget.product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${widget.product.name} added to cart.'), duration: Duration(seconds: 2)),
                                  );
                                },
                                label: const Text('Add to Cart'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default: tampilan grid/portrait
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/item', arguments: widget.product);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Hero(
                    tag: widget.product.id,
                    child: widget.product.imageUrl.startsWith('http')
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            widget.product.imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.category[0].toUpperCase() + widget.product.category.substring(1),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Judul item khusus untuk cloth, wayang, other
                    if (widget.product.category.toLowerCase() == 'cloth' && (widget.product.details['item_type'] != null && widget.product.details['item_type']!.isNotEmpty))
                      Text(
                        widget.product.details['item_type']!,
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.product.category.toLowerCase() == 'wayang' && (widget.product.details['type'] != null && widget.product.details['type']!.isNotEmpty))
                      Text(
                        widget.product.details['type']!,
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.product.category.toLowerCase() == 'other' && (widget.product.description != null && widget.product.description!.isNotEmpty))
                      Text(
                        widget.product.description!,
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Untuk kategori lain tetap pakai nama
                    if (!(widget.product.category.toLowerCase() == 'cloth' || widget.product.category.toLowerCase() == 'wayang' || widget.product.category.toLowerCase() == 'other'))
                      Text(widget.product.name, style: textTheme.titleLarge?.copyWith(fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    if (widget.product.description != null && widget.product.description!.isNotEmpty)
                      Text(widget.product.description!, style: textTheme.bodyMedium),
                    if (widget.product.details['artist'] != null && widget.product.details['artist']!.isNotEmpty)
                      Text('Artist: ${widget.product.details['artist']}', style: textTheme.bodyMedium),
                    if (widget.product.details['technique'] != null && widget.product.details['technique']!.isNotEmpty)
                      Text('Technique: ${widget.product.details['technique']}', style: textTheme.bodyMedium),
                    if (widget.product.details['dimensions'] != null && widget.product.details['dimensions']!.isNotEmpty)
                      Text('Dimensions: ${widget.product.details['dimensions']}', style: textTheme.bodyMedium),
                    if (widget.product.details['year'] != null && widget.product.details['year']!.isNotEmpty)
                      Text('Year: ${widget.product.details['year']}', style: textTheme.bodyMedium),
                    if (widget.product.details['code'] != null && widget.product.details['code']!.isNotEmpty)
                      Text('Code: ${widget.product.details['code']}', style: textTheme.bodyMedium),
                    if (widget.product.details['maker'] != null && widget.product.details['maker']!.isNotEmpty)
                      Text('Maker: ${widget.product.details['maker']}', style: textTheme.bodyMedium),
                    if (widget.product.details['item_type'] != null && widget.product.details['item_type']!.isNotEmpty)
                      Text('Item Type: ${widget.product.details['item_type']}', style: textTheme.bodyMedium),
                    if (widget.product.details['type'] != null && widget.product.details['type']!.isNotEmpty)
                      Text('Type: ${widget.product.details['type']}', style: textTheme.bodyMedium),
                    if (widget.product.details['region'] != null && widget.product.details['region']!.isNotEmpty)
                      Text('Region: ${widget.product.details['region']}', style: textTheme.bodyMedium),
                    if (widget.product.details['puppeteer'] != null && widget.product.details['puppeteer']!.isNotEmpty)
                      Text('Puppeteer: ${widget.product.details['puppeteer']}', style: textTheme.bodyMedium),
                    if (widget.product.details['estimated_value'] != null && widget.product.details['estimated_value']!.isNotEmpty)
                      Text('Estimated Value: ${widget.product.details['estimated_value']}', style: textTheme.bodyMedium),
                    if (widget.product.notes != null && widget.product.notes!.isNotEmpty)
                      Text('Notes: ${widget.product.notes!}', style: textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Text(
                      formatter.format(widget.product.price),
                      style: textTheme.headlineMedium?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: colorScheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => _ImageZoomDialog(product: widget.product),
                              );
                            },
                            child: const Text('View Detail'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              final cart = Provider.of<CartProvider>(context, listen: false);
                              cart.addItem(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${widget.product.name} added to cart.'), duration: Duration(seconds: 2)),
                              );
                            },
                            label: const Text('Add to Cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageZoomDialog extends StatefulWidget {
  final Product product;
  const _ImageZoomDialog({required this.product});

  @override
  State<_ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<_ImageZoomDialog> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  bool _isLongPress = false;

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPress = true;
      _previousScale = _scale;
      _previousOffset = _offset;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_isLongPress) {
      setState(() {
        _offset += details.offsetFromOrigin / _scale;
      });
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isLongPress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: 400,
          height: 540,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onScaleStart: (details) {
                    _previousScale = _scale;
                    _previousOffset = _offset;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                      _offset = _previousOffset + (details.focalPoint - details.localFocalPoint) / _scale;
                    });
                  },
                  onScaleEnd: (_) {
                    setState(() {
                      _previousScale = 1.0;
                      _previousOffset = _offset;
                    });
                  },
                  onLongPressStart: _onLongPressStart,
                  onLongPressMoveUpdate: _onLongPressMoveUpdate,
                  onLongPressEnd: _onLongPressEnd,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(_offset.dx, _offset.dy)
                      ..scale(_isLongPress ? 2.0 : _scale),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: product.imageUrl.startsWith('http')
                        ? Image.network(product.imageUrl, fit: BoxFit.contain, width: double.infinity, height: 260)
                        : Image.asset(product.imageUrl, fit: BoxFit.contain, width: double.infinity, height: 260),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(product.description ?? '', style: textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        ...product.details.entries.where((e) => e.key != 'name' && e.key != 'image_url' && e.value.isNotEmpty).map((entry) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('${entry.key[0].toUpperCase() + entry.key.substring(1).replaceAll('_', ' ')}: ${entry.value}', style: textTheme.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}