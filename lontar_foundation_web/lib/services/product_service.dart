import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  Future<List<Product>> loadProducts() async {
    final String jsonString = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  // Ambil data dari Firestore
  Future<List<Product>> fetchProductsFromFirestore(String category, {String? orderBy}) async {
    Query collection = FirebaseFirestore.instance.collection(category);
    if (orderBy != null) {
      collection = collection.orderBy(orderBy);
    }
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id, category)).toList();
  }
} 