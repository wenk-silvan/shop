import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const route = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    title: '',
    id: null,
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isLoading = false;

  @override
  void initState() {
    this._imageUrlFocusNode.addListener(this._updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        this._editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        this._initValues = {
          'title': this._editedProduct.title,
          'description': this._editedProduct.description,
          'price': this._editedProduct.price.toString(),
          'imageUrl': '',
        };
        this._imageUrlController.text = this._editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._imageUrlFocusNode.removeListener(this._updateImageUrl);
    this._priceFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    this._imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!this._imageUrlFocusNode.hasFocus) {
      if ((!this._imageUrlController.text.startsWith('http') &&
              !this._imageUrlController.text.startsWith('https')) ||
          (!this._imageUrlController.text.endsWith('.png') &&
              !this._imageUrlController.text.endsWith('.jpg') &&
              !this._imageUrlController.text.endsWith('jpeg'))) return;
      setState(() {});
    }
  }

  void _safeForm() async {
    if (!this._form.currentState.validate()) return;
    this._form.currentState.save();
    setState(() {
      this._isLoading = true;
    });
    if (this._editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(this._editedProduct.id, this._editedProduct);
      setState(() {
        this._isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(this._editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured!'),
                  content: Text('Something went wrong.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      } finally {
        setState(() {
          this._isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this._safeForm,
          ),
        ],
      ),
      body: this._isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: this._form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: this._initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(this._priceFocusNode),
                      onSaved: (value) => this._editedProduct = Product(
                        title: value,
                        imageUrl: this._editedProduct.imageUrl,
                        description: this._editedProduct.description,
                        price: this._editedProduct.price,
                        id: this._editedProduct.id,
                        isFavorite: this._editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a title.';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: this._priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(this._descriptionFocusNode),
                      onSaved: (value) => this._editedProduct = Product(
                        title: this._editedProduct.title,
                        imageUrl: this._editedProduct.imageUrl,
                        description: this._editedProduct.description,
                        price: double.parse(value),
                        id: this._editedProduct.id,
                        isFavorite: this._editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a price.';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number';
                        if (double.parse(value) <= 0)
                          return 'Has to be greater than zero.';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: this._descriptionFocusNode,
                      onSaved: (value) => this._editedProduct = Product(
                        title: this._editedProduct.title,
                        imageUrl: this._editedProduct.imageUrl,
                        description: value,
                        price: this._editedProduct.price,
                        id: this._editedProduct.id,
                        isFavorite: this._editedProduct.isFavorite,
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a description.';
                        if (value.length < 10)
                          return 'Should be at least 10 characters long';
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: this._imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                      this._imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: this._imageUrlController,
                            focusNode: this._imageUrlFocusNode,
                            onFieldSubmitted: (_) => this._safeForm(),
                            onSaved: (value) => this._editedProduct = Product(
                              title: this._editedProduct.title,
                              imageUrl: value,
                              description: this._editedProduct.description,
                              price: this._editedProduct.price,
                              id: this._editedProduct.id,
                              isFavorite: this._editedProduct.isFavorite,
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL.';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL';
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('jpeg'))
                                return 'Please enter a valid image URL';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
