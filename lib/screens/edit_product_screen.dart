import 'package:flutter/material.dart';

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
  
  @override
  void initState() {
    this._imageUrlFocusNode.addListener(this._updateImageUrl);
    super.initState();
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
    if(!this._imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(this._priceFocusNode),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: this._priceFocusNode,
                onFieldSubmitted: (_) => FocusScope.of(context)
                    .requestFocus(this._descriptionFocusNode),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: this._descriptionFocusNode,
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
                            child: Image.network(this._imageUrlController.text),
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
