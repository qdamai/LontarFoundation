import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';

// Tambahkan enum SortBy di top-level

enum SortBy { name, code }

class ProductListPage extends StatefulWidget {
  final String category;
  const ProductListPage({required this.category, super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;
  // Hapus variabel _sortBy dan enum SortBy jika tidak dipakai lagi

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProductsFromFirestore(widget.category.toLowerCase(), orderBy: 'order');
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    ValueNotifier<String> searchQuery = ValueNotifier('');

    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error:  ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found in this category.'));
                }
                
                final products = snapshot.data!;
                // Tidak ada sorting di UI, hanya tampilkan urutan dari Firestore
                final sortedProducts = products;

                return ValueListenableBuilder<String>(
                  valueListenable: searchQuery,
                  builder: (context, query, _) {
                    final filtered = products.where((p) {
                      final q = query.toLowerCase();
                      return p.name.toLowerCase().contains(q)
                        || (p.description?.toLowerCase().contains(q) ?? false)
                        || p.price.toString().contains(q)
                        || p.details.values.any((v) => v.toLowerCase().contains(q));
                    }).toList();
                    return Column(
                      children: [
                        // Hapus dropdown sort by
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(24.0),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.category.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                                      ),
                                      const SizedBox(height: 24),
                                      if (widget.category.toLowerCase() == 'book')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Since its founding, in 1987, Lontar has published more than 250 titles, many of which are landmark works that took years—sometimes decades—and hundreds of million rupiah to produce. These are books that every cultured household should have on its bookshelf. For a limited time only—during this 'ABC' sales period— Lontar is offering these books to readers at substantial discounts. Take advantage of this offer now!",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      if (widget.category.toLowerCase() == 'art')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Over the years, Lontar has held numerous exhibitions, featuring, primarily, the work of young and emerging artists. Especially prominent in the artwork Lontar holds on commission is graphic art. Artwork is always a good investment, almost never dropping in value from its original price and generally increasing in value exponentially over the years ahead. Though major collectors tend to buy large-size oil paintings what normal person has either the wherewithal to buy such work or the room to display it? 'Small' can be just as beautiful as 'Big' and by purchasing smaller sized artwork, one is also helping artists who must deserve it. All that said, Lontar does have in its collection, a number of larger works by well known artists and an eclectic assortment of other artistic items that are just waiting to move to your walls.",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      if (widget.category.toLowerCase() == 'wayang')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Lontar has 13 sets of Indonesian puppets (wayang) that are looking for new homes. The estimated value of each set is included in the description for each set below but what makes each set even more valuable are two things. The first is that we have the metadata for each of the puppets. The second is the large number of professional photographs associated with each of the sets. (Almost all the puppets were photographed from different angles at least ten times.) The price of each set is negotiable but new 'homeowners' who are willing to pay the full estimated value of a set will be given, free of charge, all the photographs associated with the set. For each of the sets in Lontar's possession, we provide two sample photographs. We expect that potential collectors will want to examine the sets at Lontar's office.",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      if (widget.category.toLowerCase() == 'cloth')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Lontar's cloth (kain) collection is made up primarily of vintage garments - kain panjang, selendang, sarong, stoles, and scarves - created by Indonesia's top cloth designers. Almost never worn by their previous owner - some even have their tags still on them! - these garments are in pristine condition and as stunningly beautiful today as when they were created several decades ago.",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      if (widget.category.toLowerCase() == 'other')
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Text(
                                            "Remember how, over the years, your family's home gradually filled up with items your parents had inherited, knick-knacks they had purchased, and oleh-oleh from trips to other cities and countries? Well, a similar thing has happened to Lontar and now it's time to find new homes for many of them. Please help us in this endeavor.",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      TextField(
                                        controller: searchController,
                                        decoration: const InputDecoration(
                                          hintText: 'Cari produk (judul, harga, deskripsi, author, dll)',
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) => searchQuery.value = val,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                sliver: widget.category.toLowerCase() == 'book'
                                  ? SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final product = filtered.isNotEmpty ? filtered[index] : sortedProducts[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 110,
                                                  height: 150,
                                                  margin: const EdgeInsets.only(right: 24),
                                                  child: product.imageUrl.startsWith('http')
                                                    ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                                                    : Image.asset(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(product.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                                                      const SizedBox(height: 6),
                                                      if (product.description != null && product.description!.isNotEmpty)
                                                        Text(product.description!, style: Theme.of(context).textTheme.bodyLarge),
                                                      const SizedBox(height: 8),
                                                      if (product.details['code'] != null && product.details['code']!.isNotEmpty)
                                                        Text('Code: ${product.details['code']}', style: Theme.of(context).textTheme.bodyMedium),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(product.price),
                                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          FilledButton(
                                                            onPressed: () {
                                                              Navigator.pushNamed(context, '/item', arguments: product);
                                                            },
                                                            child: const Text('View Detail'),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          FilledButton.icon(
                                                            icon: const Icon(Icons.add_shopping_cart),
                                                            onPressed: () {
                                                              final cart = Provider.of<CartProvider>(context, listen: false);
                                                              cart.addItem(product);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('${product.name} added to cart.'), duration: Duration(seconds: 2)),
                                                              );
                                                            },
                                                            label: const Text('Add to Cart'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        childCount: filtered.isNotEmpty ? filtered.length : sortedProducts.length,
                                      ),
                                    )
                                  : SliverGrid(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 400,
                                        childAspectRatio: 2 / 3,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => ProductCard(product: filtered.isNotEmpty ? filtered[index] : sortedProducts[index]),
                                        childCount: filtered.isNotEmpty ? filtered.length : sortedProducts.length,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const LontarFooter(),
        ],
      ),
    );
  }
}

// Footer Lontar Foundation
class LontarFooter extends StatelessWidget {
  const LontarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // lebih kecil
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(thickness: 1),
          const SizedBox(height: 8), // lebih kecil
          Text(
            '© 2024 Lontar Foundation. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Contact: contact@lontar.org | WhatsApp: +628164812155',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.language, size: 16),
                tooltip: 'Website',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.facebook, size: 16),
                tooltip: 'Facebook',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, size: 16),
                tooltip: 'Instagram',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
} 