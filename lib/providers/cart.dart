import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    this._items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  int get itemCount {
    return this._items.length;
  }

  void addItem(String productId, double price, String title) {
    if (this._items.containsKey(productId)) {
      this._items.update(
          productId,
          (existingCartItem) => CartItem(
                quantity: existingCartItem.quantity + 1,
                price: existingCartItem.price,
                title: existingCartItem.title,
                id: existingCartItem.id,
              ));
    } else {
      this._items.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    this.notifyListeners();
  }

  void removeItem(String productId) {
    this._items.remove(productId);
    this.notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!this._items.containsKey(productId)) return;
    if (this._items[productId].quantity > 1) {
      this._items.update(productId, (existingCartItem) => CartItem(
        quantity: existingCartItem.quantity - 1,
        price: existingCartItem.price,
        id: existingCartItem.id,
        title: existingCartItem.title
      ));
    } else {
      this._items.remove(productId);
    }
    this.notifyListeners();
  }

  void clear() {
    this._items = {};
    this.notifyListeners();
  }
}
