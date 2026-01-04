class Product {
  final String id;
  final String category;
  final String name;
  final String? description;
  final int price;
  final String imageUrl;
  final Map<String, String> details;
  final String? notes;

  Product({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.details,
    this.notes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? getName(Map<String, dynamic> json) {
      return json['name'] as String? ?? json['title'] as String? ?? json['nama'] as String? ?? '';
    }
    String? getDescription(Map<String, dynamic> json) {
      return json['description'] as String? ?? json['short_description'] as String? ?? json['deskripsi'] as String?;
    }
    String? getNotes(Map<String, dynamic> json) {
      return json['notes'] as String? ?? json['catatan'] as String?;
    }
    int getPrice(Map<String, dynamic> json) {
      if (json['sale_price'] != null && json['sale_price'].toString().isNotEmpty) {
        return json['sale_price'] is int ? json['sale_price'] : int.tryParse(json['sale_price'].toString()) ?? 0;
      }
      if (json['list_price'] != null && json['list_price'].toString().isNotEmpty) {
        return json['list_price'] is int ? json['list_price'] : int.tryParse(json['list_price'].toString()) ?? 0;
      }
      if (json['price'] != null && json['price'].toString().isNotEmpty) {
        return json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0;
      }
      if (json['estimated_value'] != null && json['estimated_value'].toString().isNotEmpty) {
        return json['estimated_value'] is int ? json['estimated_value'] : int.tryParse(json['estimated_value'].toString()) ?? 0;
      }
      if (json['value'] != null && json['value'].toString().isNotEmpty) {
        return json['value'] is int ? json['value'] : int.tryParse(json['value'].toString()) ?? 0;
      }
      return 0;
    }
    return Product(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      name: getName(json) ?? '',
      description: getDescription(json),
      price: getPrice(json),
      imageUrl: json['cover_url'] as String? ?? json['image_url'] as String? ?? '',
      details: json.map((key, value) => MapEntry(key, value?.toString() ?? '')),
      notes: getNotes(json),
    );
  }

  factory Product.fromFirestore(Map<String, dynamic> json, String docId, String category) {
    String? getName(Map<String, dynamic> json) {
      return json['name'] as String? ?? json['title'] as String? ?? json['nama'] as String? ?? '';
    }
    String? getDescription(Map<String, dynamic> json) {
      return json['description'] as String? ?? json['short_description'] as String? ?? json['deskripsi'] as String?;
    }
    String? getNotes(Map<String, dynamic> json) {
      return json['notes'] as String? ?? json['catatan'] as String?;
    }
    int getPrice(Map<String, dynamic> json, String category) {
      if (json['sale_price'] != null && json['sale_price'].toString().isNotEmpty) {
        return json['sale_price'] is int ? json['sale_price'] : int.tryParse(json['sale_price'].toString()) ?? 0;
      }
      if (json['list_price'] != null && json['list_price'].toString().isNotEmpty) {
        return json['list_price'] is int ? json['list_price'] : int.tryParse(json['list_price'].toString()) ?? 0;
      }
      if (json['price'] != null && json['price'].toString().isNotEmpty) {
        return json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0;
      }
      if (json['estimated_value'] != null && json['estimated_value'].toString().isNotEmpty) {
        return json['estimated_value'] is int ? json['estimated_value'] : int.tryParse(json['estimated_value'].toString()) ?? 0;
      }
      if (json['value'] != null && json['value'].toString().isNotEmpty) {
        return json['value'] is int ? json['value'] : int.tryParse(json['value'].toString()) ?? 0;
      }
      return 0;
    }
    return Product(
      id: docId,
      category: category,
      name: getName(json) ?? '',
      description: getDescription(json),
      price: getPrice(json, category),
      imageUrl: json['cover_url'] as String? ?? json['image_url'] as String? ?? '',
      details: json.map((key, value) => MapEntry(key, value?.toString() ?? '')),
      notes: getNotes(json),
    );
  }
} 