import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('MyShop'),
            automaticallyImplyLeading: false, //Never shows back button
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(OrdersScreen.route),
          ),
        ],
      ),
    );
  }
}
