import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Hapus karena belum dipakai langsung
import 'package:reorderables/reorderables.dart';

// Tambahkan enum SortMode di top-level

enum SortMode { none, name, code }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD3oZBv9snxqulidSgKTsH06TPT8D8EVPM",
      authDomain: "lontar-abcs.firebaseapp.com",
      projectId: "lontar-abcs",
      storageBucket: "lontar-abcs.appspot.com",
      messagingSenderId: "433827741036",
      appId: "1:433827741036:web:0821e2f148196489c68749",
      measurementId: "G-HJKXGF11CS",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lontar Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const AdminDashboard();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> login() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 350,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Lontar Admin Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        child: isLoading ? const CircularProgressIndicator() : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Mulai dashboard dan form dinamis

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? selectedCategory;

  final List<String> categories = [
    'Art', 'Book', 'Wayang', 'Cloth', 'Other', 'Carousel'
  ];

  // Tambahkan deskripsi dan icon untuk setiap kategori
  final Map<String, Map<String, dynamic>> categoryDetails = {
    'Art': {
      'icon': Icons.brush,
      'desc': 'Manage artworks, including artist, title, and technique.'
    },
    'Book': {
      'icon': Icons.book,
      'desc': 'Manage book collections, prices, and descriptions.'
    },
    'Wayang': {
      'icon': Icons.theater_comedy,
      'desc': 'Manage wayang puppets, types, and makers.'
    },
    'Cloth': {
      'icon': Icons.checkroom,
      'desc': 'Manage traditional cloths, materials, and makers.'
    },
    'Other': {
      'icon': Icons.category,
      'desc': 'Manage other unique items in the collection.'
    },
    'Carousel': {
      'icon': Icons.image,
      'desc': 'Manage images for the homepage carousel.'
    },
  };

  // Fungsi utilitas untuk update field order pada data lama
  Future<void> updateOrderForOldDocs(String collectionName) async {
    final col = FirebaseFirestore.instance.collection(collectionName);
    final snapshot = await col.get();
    int i = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('order')) {
        await col.doc(doc.id).update({'order': i});
      }
      i++;
    }
  }

  Future<void> fixAllOldData() async {
    for (final col in categories) {
      await updateOrderForOldDocs(col.toLowerCase());
    }
    setState(() {});
    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    fixAllOldData();
  }

  // Tambahkan builder untuk card kategori
  Widget _buildCategoryCard(String name, IconData icon, String description) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = name),
      child: SizedBox(
        width: 200, // Lebar tetap
        height: 200, // Tinggi tetap
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.brown[400]),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Logout',
          ),
          TextButton.icon(
            icon: const Icon(Icons.build, color: Colors.white),
            label: const Text('Perbaiki Data Lama', style: TextStyle(color: Colors.white)),
            onPressed: fixAllOldData,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: selectedCategory == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Category:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Please select a category to manage its data. Each category represents a different type of collection in the Lontar Foundation database.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: categories.map((cat) => _buildCategoryCard(
                        cat,
                        categoryDetails[cat]!['icon'],
                        categoryDetails[cat]!['desc'],
                      )).toList(),
                    ),
                  ],
                )
              : selectedCategory == 'Carousel'
                  ? CarouselForm(onBack: () => setState(() => selectedCategory = null))
                  : CategoryForm(
                      category: selectedCategory!,
                      onBack: () => setState(() => selectedCategory = null),
                    ),
        ),
      ),
    );
  }
}

class CategoryForm extends StatefulWidget {
  final String category;
  final VoidCallback onBack;
  const CategoryForm({required this.category, required this.onBack, super.key});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  bool isLoading = false;
  String? errorMessage;
  String? editingDocId;

  // Tambahkan enum untuk mode sort UI
  // enum SortMode { none, name, code } // Hapus deklarasi enum SortMode di dalam class _CategoryFormState jika ada
  SortMode _sortMode = SortMode.none; // Untuk feedback loading saat update order
  bool _isSorting = false; // Untuk feedback loading saat update order

  Map<String, List<Map<String, String>>> get fieldsPerCategory => {
    'Art': [
      {'artist': 'Artist'},
      {'title': 'Title'},
      {'technique': 'Technique'},
      {'dimensions': 'Dimensions'},
      {'year': 'Year'},
      {'price': 'Price'},
      {'code': 'Code'},
      {'image_url': 'Image URL'},
      {'description': 'Description (optional)'},
    ],
    'Book': [
      {'title': 'Title'},
      {'short_description': 'Short Description'},
      {'list_price': 'List Price'},
      {'sale_price': 'Sale Price'},
      {'code': 'Code'},
      {'cover_url': 'Cover URL'},
      {'additional_info': 'Additional Info (JSON, optional)'},
    ],
    'Wayang': [
      {'type': 'Type of Puppet'},
      {'region': 'Region'},
      {'puppeteer': 'Puppeteer'},
      {'maker': 'Maker'},
      {'number_of_puppets': 'Number of Puppets'},
      {'number_of_photos': 'Number of Photos'},
      {'year_purchased': 'Year Purchased'},
      {'estimated_value': 'Estimated Value'},
      {'code': 'Code'},
      {'image_url': 'Image URL'},
      {'description': 'Description'},
    ],
    'Cloth': [
      {'item_type': 'Item Type'},
      {'maker': 'Maker'},
      {'colors_material': 'Colors & Material'},
      {'dimensions': 'Dimensions'},
      {'year_purchased': 'Year Purchased'},
      {'estimated_value': 'Estimated Value'},
      {'code': 'Code'},
      {'image_url': 'Image URL'},
      {'notes': 'Notes'},
    ],
    'Other': [
      {'item_name': 'Item Name'},
      {'description': 'Description'},
      {'dimensions': 'Dimensions'},
      {'year_of_creation': 'Year of Creation'},
      {'estimated_value': 'Estimated Value'},
      {'code': 'Code'},
      {'image_url': 'Image URL'},
      {'notes': 'Notes'},
    ],
  };

  @override
  void initState() {
    super.initState();
    for (var field in fieldsPerCategory[widget.category]!) {
      controllers[field.keys.first] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void fillForm(Map<String, dynamic> data, String docId) {
    for (var key in controllers.keys) {
      controllers[key]?.text = data[key]?.toString() ?? '';
    }
    setState(() {
      editingDocId = docId;
    });
  }

  void clearForm() {
    for (var c in controllers.values) {
      c.clear();
    }
    setState(() {
      editingDocId = null;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = <String, dynamic>{};
      controllers.forEach((key, ctrl) {
        data[key] = ctrl.text.trim();
      });
      final col = FirebaseFirestore.instance.collection(widget.category.toLowerCase());
      if (editingDocId != null) {
        await col.doc(editingDocId).update(data);
      } else {
        final querySnapshot = await col.orderBy('order', descending: true).limit(1).get();
        int newOrder = 0;
        if (querySnapshot.docs.isNotEmpty) {
          final lastOrderData = querySnapshot.docs.first.data();
          if (lastOrderData.containsKey('order') && lastOrderData['order'] is int) {
            newOrder = lastOrderData['order'] + 1;
          } else {
             newOrder = querySnapshot.docs.length;
          }
        }
        data['order'] = newOrder;
        await col.add(data);
      }
      clearForm();
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> deleteDoc(String docId) async {
    final col = FirebaseFirestore.instance.collection(widget.category.toLowerCase());
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = col.doc(docId);
      final docSnapshot = await transaction.get(docRef);

      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final orderToDelete = data.containsKey('order') ? data['order'] as int : -1;

      transaction.delete(docRef);

      if (orderToDelete == -1) return;

      final subsequentDocs = await col.where('order', isGreaterThan: orderToDelete).get();
      for (final doc in subsequentDocs.docs) {
        transaction.update(doc.reference, {'order': (doc.data()['order'] as int) - 1});
      }
    });

    if (editingDocId == docId) clearForm();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fields = fieldsPerCategory[widget.category]!;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                          Expanded(
                            child: Row(
                              children: [
                                const Expanded(child: Divider(thickness: 2, endIndent: 12)),
                                Text(
                                  widget.category[0].toUpperCase() + widget.category.substring(1),
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                  textAlign: TextAlign.center,
                                ),
                                const Expanded(child: Divider(thickness: 2, indent: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ...fields.map((field) {
                        final key = field.keys.first;
                        final label = field.values.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: controllers[key],
                            decoration: InputDecoration(
                              labelText: label,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            validator: (v) => (v == null || v.isEmpty) && !label.toLowerCase().contains('optional') ? 'Required' : null,
                          ),
                        );
                      }),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 2,
                                ),
                                onPressed: isLoading ? null : submit,
                                child: isLoading ? const CircularProgressIndicator() : Text(editingDocId == null ? 'Submit' : 'Update'),
                              ),
                            ),
                          ),
                          if (editingDocId != null) ...[
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isLoading ? null : clearForm,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: const Text('Cancel'),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Tombol aksi sorting & drag
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sort_by_alpha),
                            label: const Text('Sort Nama (UI)'),
                            style: ElevatedButton.styleFrom(backgroundColor: _sortMode == SortMode.name ? Colors.brown : null),
                            onPressed: () {
                              setState(() { _sortMode = _sortMode == SortMode.name ? SortMode.none : SortMode.name; });
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.numbers),
                            label: const Text('Sort Kode (UI)'),
                            style: ElevatedButton.styleFrom(backgroundColor: _sortMode == SortMode.code ? Colors.brown : null),
                            onPressed: () {
                              setState(() { _sortMode = _sortMode == SortMode.code ? SortMode.none : SortMode.code; });
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sync),
                            label: _isSorting ? const Text('Menyimpan...') : const Text('Urutkan Otomatis (Simpan)'),
                            onPressed: _isSorting ? null : () async {
                              setState(() { _isSorting = true; });
                              // Ambil snapshot data
                              final col = FirebaseFirestore.instance.collection(widget.category.toLowerCase());
                              final snap = await col.orderBy('order').get();
                              List<QueryDocumentSnapshot> docs = snap.docs;
                              if (_sortMode == SortMode.name) {
                                docs.sort((a, b) {
                                  final aName = (a.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                  final bName = (b.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                  return aName.compareTo(bName);
                                });
                              } else if (_sortMode == SortMode.code) {
                                docs.sort((a, b) {
                                  final aCode = (a.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                  final bCode = (b.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                  return aCode.compareTo(bCode);
                                });
                              }
                              final batch = FirebaseFirestore.instance.batch();
                              for (int i = 0; i < docs.length; i++) {
                                batch.update(docs[i].reference, {'order': i});
                              }
                              await batch.commit();
                              setState(() { _isSorting = false; });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text('↕️ Drag & Drop untuk atur urutan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.brown[50],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Riwayat Data:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection(widget.category.toLowerCase()).orderBy('order').snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return const Text('Belum ada data.');
                                  }
                                  final docs = snapshot.data!.docs;
                                  // Sorting UI jika dipilih
                                  List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
                                  if (_sortMode == SortMode.name) {
                                    sortedDocs.sort((a, b) {
                                      final aName = (a.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                      final bName = (b.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                      return aName.compareTo(bName);
                                    });
                                  } else if (_sortMode == SortMode.code) {
                                    sortedDocs.sort((a, b) {
                                      final aCode = (a.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                      final bCode = (b.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                      return aCode.compareTo(bCode);
                                    });
                                  }
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = (constraints.maxWidth ~/ 220).clamp(1, 6);
                                      return ReorderableWrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        needsLongPressDraggable: false, // drag & drop langsung aktif tanpa long press
                                        buildDraggableFeedback: (context, constraints, child) => Material(
                                          elevation: 12,
                                          color: Colors.transparent,
                                          child: Opacity(
                                            opacity: 0.85,
                                            child: child,
                                          ),
                                        ),
                                        onReorder: (oldIndex, newIndex) async {
                                          if (oldIndex == newIndex) return;
                                          // Ambil dokumen yang sudah diurutkan sesuai tampilan
                                          List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
                                          if (_sortMode == SortMode.name) {
                                            sortedDocs.sort((a, b) {
                                              final aName = (a.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                              final bName = (b.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? '';
                                              return aName.compareTo(bName);
                                            });
                                          } else if (_sortMode == SortMode.code) {
                                            sortedDocs.sort((a, b) {
                                              final aCode = (a.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                              final bCode = (b.data() as Map<String, dynamic>)['code']?.toString().toLowerCase() ?? '';
                                              return aCode.compareTo(bCode);
                                            });
                                          }
                                          final moved = sortedDocs.removeAt(oldIndex);
                                          sortedDocs.insert(newIndex, moved);
                                          final batch = FirebaseFirestore.instance.batch();
                                          for (int i = 0; i < sortedDocs.length; i++) {
                                            batch.update(sortedDocs[i].reference, {'order': i});
                                          }
                                          await batch.commit();
                                        },
                                        children: List.generate(sortedDocs.length, (i) {
                                          final doc = sortedDocs[i];
                                          final data = doc.data() as Map<String, dynamic>;
                                          final imgUrl = data['image_url'] ?? data['cover_url'] ?? '';
                                          final title = data['title'] ?? data['name'] ?? data[fields[0].keys.first] ?? '-';
                                          final code = data['code'] ?? '';
                                          return SizedBox(
                                            width: (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount,
                                            child: Card(
                                              key: ValueKey(doc.id),
                                              elevation: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  if (imgUrl.isNotEmpty)
                                                    AspectRatio(
                                                      aspectRatio: 3/4,
                                                      child: imgUrl.startsWith('http')
                                                        ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                                                        : Image.asset(imgUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                                                    ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                        if (code.isNotEmpty) Text('Code: $code', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(Icons.edit, size: 20),
                                                              tooltip: 'Edit',
                                                              onPressed: () => fillForm(data, doc.id),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(Icons.delete, size: 20),
                                                              tooltip: 'Delete',
                                                              onPressed: () => deleteDoc(doc.id),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarouselForm extends StatefulWidget {
  final VoidCallback onBack;
  const CarouselForm({required this.onBack, super.key});

  @override
  State<CarouselForm> createState() => _CarouselFormState();
}

class _CarouselFormState extends State<CarouselForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String? editingDocId;

  @override
  void dispose() {
    titleController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void fillForm(Map<String, dynamic> data, String docId) {
    titleController.text = data['title'] ?? '';
    imageUrlController.text = data['image_url'] ?? '';
    setState(() { editingDocId = docId; });
  }

  void clearForm() {
    titleController.clear();
    imageUrlController.clear();
    setState(() { editingDocId = null; });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final data = {
        'title': titleController.text.trim(),
        'image_url': imageUrlController.text.trim(),
      };
      final col = FirebaseFirestore.instance.collection('carousel');
      if (editingDocId != null) {
        await col.doc(editingDocId).update(data);
      } else {
        final querySnapshot = await col.orderBy('order', descending: true).limit(1).get();
        int newOrder = 0;
         if (querySnapshot.docs.isNotEmpty) {
          final lastOrderData = querySnapshot.docs.first.data();
          if (lastOrderData.containsKey('order') && lastOrderData['order'] is int) {
            newOrder = lastOrderData['order'] + 1;
          } else {
             newOrder = querySnapshot.docs.length;
          }
        }
        await col.add({
          ...data,
          'order': newOrder,
        });
      }
      clearForm();
    } catch (e) {
      setState(() { errorMessage = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> deleteDoc(String docId) async {
    final col = FirebaseFirestore.instance.collection('carousel');
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = col.doc(docId);
      final docSnapshot = await transaction.get(docRef);

      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final orderToDelete = data.containsKey('order') ? data['order'] as int : -1;

      transaction.delete(docRef);

      if (orderToDelete == -1) return;

      final subsequentDocs = await col.where('order', isGreaterThan: orderToDelete).get();
      for (final doc in subsequentDocs.docs) {
        transaction.update(doc.reference, {'order': (doc.data()['order'] as int) - 1});
      }
    });
    if (editingDocId == docId) clearForm();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                        Expanded(
                          child: Row(
                            children: [
                              const Expanded(child: Divider(thickness: 2, endIndent: 12)),
                              const Text(
                                'Carousel',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                textAlign: TextAlign.center,
                              ),
                              const Expanded(child: Divider(thickness: 2, indent: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.brown[50],
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 2,
                                    ),
                                    onPressed: isLoading ? null : submit,
                                    child: isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(editingDocId == null ? 'Submit' : 'Update'),
                                  ),
                                ),
                              ),
                              if (editingDocId != null) ...[
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: isLoading ? null : clearForm,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                  child: const Text('Cancel'),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Card(
                      color: Colors.brown[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Riwayat Carousel:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('carousel').orderBy('order').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Text('Belum ada data.');
                                }
                                final docs = snapshot.data!.docs;
                                return ReorderableWrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  needsLongPressDraggable: false,
                                  buildDraggableFeedback: (context, constraints, child) => Material(
                                    elevation: 12,
                                    color: Colors.transparent,
                                    child: Opacity(
                                      opacity: 0.85,
                                      child: child,
                                    ),
                                  ),
                                  onReorder: (oldIndex, newIndex) async {
                                    if (oldIndex == newIndex) return;
                                    List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
                                    final moved = sortedDocs.removeAt(oldIndex);
                                    sortedDocs.insert(newIndex, moved);
                                    final batch = FirebaseFirestore.instance.batch();
                                    for (int i = 0; i < sortedDocs.length; i++) {
                                      batch.update(sortedDocs[i].reference, {'order': i});
                                    }
                                    await batch.commit();
                                  },
                                  children: docs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return Card(
                                      key: ValueKey(doc.id),
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      child: ListTile(
                                        leading: const Icon(Icons.drag_handle),
                                        title: Text(data['title'] ?? '-'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              tooltip: 'Edit',
                                              onPressed: () => fillForm(data, doc.id),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              tooltip: 'Delete',
                                              onPressed: () => deleteDoc(doc.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
