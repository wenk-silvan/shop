import 'dart:convert';
import 'package:flutter_complete_guide/models/http_exception.dart';

import 'product.dart';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  static const url = 'https://tutorial-shop-a3ad2.firebaseio.com';
  var authString;

  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items) {
    this.authString = '?auth=$authToken';
  }

  List<Product> get items {
    return [...this._items];
  }

  List<Product> get favoriteItems {
    return this._items.where((i) => i.isFavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post('$url/products.json$authString',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        title: product.title,
        isFavorite: product.isFavorite,
      );
      this._items.add(newProduct);
      this.notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(url + '/products.json$authString');
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extracted == null) return;

      final favoriteResponse =
          await http.get(url + '/userFavorites/$userId.json$authString');
      final favoriteData = json.decode(favoriteResponse.body);

      extracted.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          price: productData["price"],
          description: productData["description"],
          imageUrl: productData["imageUrl"],
          title: productData["title"],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      this._items = loadedProducts;
      this.notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Product findById(String id) {
    return this._items.firstWhere((p) => p.id == id);
  }

  void removeProduct(String id) async {
    final existingProductIndex = this._items.indexWhere((i) => i.id == id);
    var existingProduct = this._items[existingProductIndex];
    this._items.removeAt(existingProductIndex);
    this.notifyListeners();
    final response = await http.delete(url + '/products/$id.json$authString');
    if (response.statusCode >= 400) {
      this._items.insert(existingProductIndex, existingProduct);
      this.notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  Future<void> updateProduct(String id, Product existingProduct) async {
    final productIndex =
        this._items.indexWhere((p) => p.id == existingProduct.id);
    if (productIndex >= 0) {
      await http.patch(url + '/products/$id.json$authString',
          body: json.encode({
            'title': existingProduct.title,
            'description': existingProduct.description,
            'imageUrl': existingProduct.imageUrl,
            'price': existingProduct.price,
          }));
      this._items[productIndex] = existingProduct;
    }
  }
}
