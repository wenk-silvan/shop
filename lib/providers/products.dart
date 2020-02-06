import 'dart:convert';
import 'product.dart';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  static const url = 'https://tutorial-shop-a3ad2.firebaseio.com';

  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  List<Product> get items {
    return [...this._items];
  }

  List<Product> get favoriteItems {
    return this._items.where((i) => i.isFavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(url + '/products.json',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
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
      final response = await http.get(url + '/products.json');
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extracted.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          price: productData["price"],
          description: productData["description"],
          imageUrl: productData["imageUrl"],
          title: productData["title"],
          isFavorite: productData["isFavorite"],
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

  void removeProduct(String id) {
    this._items.removeWhere((i) => i.id == id);
    this.notifyListeners();
  }

  Future<void> updateProduct(String id, Product existingProduct) async {
    final productIndex =
        this._items.indexWhere((p) => p.id == existingProduct.id);
    if (productIndex >= 0) {
      await http.patch(url + '/products/$id.json', body: json.encode({
        'title': existingProduct.title,
        'description': existingProduct.description,
        'imageUrl': existingProduct.imageUrl,
        'price': existingProduct.price,
      }));
      this._items[productIndex] = existingProduct;
    } else {
      print('...');
    }
  }
}
