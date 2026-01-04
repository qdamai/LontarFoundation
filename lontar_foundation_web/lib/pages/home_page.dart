import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class _ArtImageCard extends StatefulWidget {
  final Product product;
  const _ArtImageCard({required this.product});

  @override
  State<_ArtImageCard> createState() => _ArtImageCardState();
}

class _ArtImageCardState extends State<_ArtImageCard> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => {}),
      onExit: (_) => setState(() => {}),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _ImageZoomDialog(product: widget.product),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: widget.product.imageUrl.startsWith('http')
                      ? Image.network(widget.product.imageUrl, fit: BoxFit.contain, width: double.infinity)
                      : Image.asset(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Text(
                  widget.product.name,
                  style: textTheme.titleLarge?.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchAllProducts();
  }

  Future<List<Product>> fetchAllProducts() async {
    final categories = ['art', 'book', 'cloth', 'other', 'wayang'];
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    List<Product> all = [];
    for (final cat in categories) {
      all.addAll(await _productService.fetchProductsFromFirestore(cat));
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState();
          }
          final products = snapshot.data!;
          return _buildPageContent(context, products);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          const Text("Data belum tersedia."),
          const Text("Silakan periksa kembali file assets/data/products.json."),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  
  Widget _buildPageContent(BuildContext context, List<Product> products) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Flexible(child: Divider(thickness: 1, endIndent: 20)),
                    Text("꧁", style: textTheme.headlineMedium?.copyWith(color: Colors.grey.shade400)),
                Image.asset(
                  'assets/images/logo/logolontar.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                ),
                    Text("꧂", style: textTheme.headlineMedium?.copyWith(color: Colors.grey.shade400)),
                    const Flexible(child: Divider(thickness: 1, indent: 20)),
                  ],
                ),
                const SizedBox(height: 16), // Reduced space
                Text(
                  'Art, Books, and Crafts for Indonesia',
                  style: textTheme.displayLarge?.copyWith(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  'Every work you own is a support for the continuation of our mission to preserve and promote Indonesian literature and culture to the world.',
                  style: textTheme.bodyLarge?.copyWith(fontSize: 20, height: 1.7),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),

          // Carousel Section
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('carousel').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No carousel images.'));
              }
              final carouselItems = snapshot.data!.docs;
              return CarouselSlider.builder(
                itemCount: carouselItems.length,
                itemBuilder: (context, index, realIndex) {
                  final data = carouselItems[index].data() as Map<String, dynamic>;
                  final imageUrl = data['image_url'] ?? '';
                  final title = data['title'] ?? '';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 320,
                              errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40))),
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 320,
                              errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40))),
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: 340,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 0.28,
                  aspectRatio: 1.0,
                  padEnds: false,
                ),
              );
            },
          ),
          
          const SizedBox(height: 60),

          // About Section
          // LayoutBuilder(
          //   builder: (context, constraints) {
          //     final isMobile = constraints.maxWidth < 700;
          //     return Container(
          //       width: double.infinity,
          //       color: const Color(0xFFF8F3EA), // Soft beige background
          //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          //       child: Center(
          //         child: Container(
          //           constraints: const BoxConstraints(maxWidth: 950),
          //           decoration: BoxDecoration(
          //             color: Colors.white.withAlpha((0.85 * 255).toInt()),
          //             borderRadius: BorderRadius.circular(18),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.brown.withAlpha((0.08 * 255).toInt()),
          //                 blurRadius: 24,
          //                 offset: const Offset(0, 8),
          //               ),
          //             ],
          //             border: Border.all(color: Colors.brown.withAlpha((0.08 * 255).toInt())),
          //           ),
          //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          //           child: isMobile
          //               ? Column(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     _AboutImage(),
          //                     const SizedBox(height: 28),
          //                     _AboutTextSection(),
          //                   ],
          //                 )
          //               : Row(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     Expanded(flex: 3, child: _AboutTextSection()),
          //                     const SizedBox(width: 40),
          //                     Expanded(flex: 2, child: _AboutImage()),
          //                   ],
          //                 ),
          //         ),
          //       ),
          //     );
          //   },
          // ),

          const SizedBox(height: 60),

          // About Lontar Foundation card besar di tengah (hanya satu, elegan)
          Center(
            child: Card(
              color: const Color(0xFFFFF8F0), // krem hangat
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ornamen motif di atas
                    Text(
                      '⏃⏚⏃⏚⏃⏚⏃⏚',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Introduction
                    Text(
                      'Introduction: The Lontar Foundation',
                      style: textTheme.displayLarge?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: 32,
                        color: const Color(0xFF7B3F00), // coklat tua
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '''The Lontar Foundation (Lontar), founded in 1987 for the purpose of promoting Indonesia to the world through literary translations, has published more than 250 books containing translations of literary texts by 800+ Indonesian authors. Lontar has made possible the teaching of Indonesian literature ANYWHERE in the world through the medium of English and it was Lontar, with its hundreds of titles, that made possible Indonesia's selection as Guest of Honor at the 215 Frankfurt Book Fair and the 219 London Book Fair. (For complete information about Lontar, go to www.lontar.org.)''',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.7,
                        color: const Color(0xFF4E342E), // coklat gelap
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '''Recent cancellations of grants from institutions in Indonesia (thanks to the government's "Efficiency Program") and the United States (thanks to the Department of Government Efficiency) have left Lontar without the financial reserves needed for it to continue its work. For this reason, Lontar is seeking to "transfer ownership" of Artwork it has collected, special Books it has produced, and Craftwork as well as other items the foundation has in its possession—all the "ABCs."''',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.7,
                        color: const Color(0xFF4E342E),
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 32),
                    // Divider motif
                    Text(
                      '✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: const Color(0xFFB8860B),
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Petunjuk Pembelian
                    Text(
                      'Purchase Instructions',
                      style: textTheme.displayLarge?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: 26,
                        color: const Color(0xFFA44200), // oranye batik
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To purchase an item, simply browse our catalog of artworks, books, and crafts. Click on the item you are interested in to view more details. Add the item to your cart and proceed to checkout. You may review your cart at any time by clicking the cart icon at the top right of the page. After completing your purchase, you will receive a confirmation and further instructions for collection or delivery. For any questions or to schedule a viewing, please contact us at contact@lontar.org or via WhatsApp at +628164812155.',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 1.7,
                        color: const Color(0xFF4E342E),
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 32),
                    // Divider motif
                    Text(
                      '✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: const Color(0xFFB8860B),
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Artwork
                    Text(
                      'Artwork',
                      style: textTheme.displayLarge?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: 26,
                        color: const Color(0xFF7B3F00),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Over the years, Lontar has held numerous exhibitions, featuring, primarily, the work of young and emerging artists. Especially prominent in the artwork Lontar holds on commission is graphic art. Artwork is always a good investment, almost never dropping in value from its original price and generally increasing in value exponentially over the years ahead. Though major collectors tend to buy large-size oil paintings what normal person has either the wherewithal to buy such work or the room to display it? "Small" can be just as beautiful as "Big" and by purchasing smaller sized artwork, one is also helping artists who must deserve it. All that said, Lontar does have in its collection, a number of larger works by well known artists and an eclectic assortment of other artistic items that are just waiting to move to your walls.',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 1.7,
                        color: const Color(0xFF4E342E),
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 32),
                    // Divider motif
                    Text(
                      '✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦✦',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: const Color(0xFFB8860B),
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Notes for Potential Buyers
                    Text(
                      'Notes for Potential Buyers',
                      style: textTheme.displayLarge?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: 26,
                        color: const Color(0xFF7B3F00),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '''In addition to images of the artwork, books, and craftwork (puppets, cloth, and other items) now on sale at Lontar's office, this landing page contains prices and details on the provenance of all items. It is expected that most potential buyers will want to see the item that strikes their fancy before deciding whether or not to make a purchase. Potential buyers are invited to stop by Lontar's office during regular office hours, from 10 AM to 4 PM, Monday to Friday, except for national holidays. Lontar's address is Jalan Danau Laut Tawar No. 53, Pejompongan, Jakarta 10210. Potential buyers may purchase items without seeing them first but all sales are final. No returns are permitted and no refunds will be given. Specifically in regard to items made of cloth—hand-woven silk kain, selendang, sarong, stoles, and scarves—because of their fragility, an appointment to see them is required. Send a request for an appointment to contact@lontar.org or a WA message to +628164812155. Buyers are responsible for the collection of the items they purchase. If there are any discrepancies between information on this landing page and the sales list at Lontar, the latter that shall be considered valid.''',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 1.7,
                        color: const Color(0xFF4E342E),
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),
                    // Ornamen motif di bawah
                    Text(
                      '⏃⏚⏃⏚⏃⏚⏃⏚',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 