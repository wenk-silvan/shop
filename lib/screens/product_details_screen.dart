import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
//  final String title;
//
//  ProductDetailsScreen(this.title);

  static const route = '/product-details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text("Title"),
      ),
    );
  }
}
