import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  static const url = 'https://tutorial-shop-a3ad2.firebaseio.com';
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [...this._orders];
  }

  Future<void> fetchOrders() async {
    final response = await http.get(url + '/orders/$userId.json?auth=$authToken');
    final List<OrderItem> loadedOrders = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products:
              (orderData['products'] as List<dynamic>).map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity'],
                  )).toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    this._orders = loadedOrders.reversed.toList();
    this.notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    final response = await http.post(
      url + '/orders/$userId.json?auth=$authToken',
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    this._orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp,
          ),
        );
    this.notifyListeners();
  }
}
