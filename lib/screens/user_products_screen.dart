import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:flutter_complete_guide/widgets/main_drawer.dart';
import 'package:flutter_complete_guide/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const route = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    /*final productsData = Provider.of<Products>(context);
    final products = productsData.items;*/
    print('rebuilding...');
    void addProduct(Product product) {
      Provider.of<Products>(context, listen: false).addProduct(product);
    }

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.route),
          ),
        ],
      ),
      body: FutureBuilder(
        future: this._refreshProducts(context),
        builder: (ctx, snapshot) => RefreshIndicator(
          onRefresh: () => snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : this._refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx, productsData, _) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    UserProductItem(
                      productsData.items[i],
                      addProduct,
                    ),
                    Divider(),
                  ],
                ),
                itemCount: productsData.items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
