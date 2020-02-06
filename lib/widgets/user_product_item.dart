import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  final Function addProduct;

  UserProductItem(
    this.product,
    this.addProduct,
  );

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(this.product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(this.product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.route,
                    arguments: this.product.id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .removeProduct(this.product.id);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove item.'),
                    ),
                  );
                }
                /*scaffold.showSnackBar(
                  SnackBar(
                    content: Text('Removed item.'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => this.addProduct(this.product),
                    ),
                  ),
                );*/
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
