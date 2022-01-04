import 'package:flutter/material.dart';
import 'package:shop_app/provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/products_provider.dart';

class EditeProductScreen extends StatefulWidget {
  static const routeName = '/edite-product-screen';
  @override
  _EditeProductScreenState createState() => _EditeProductScreenState();
}

class _EditeProductScreenState extends State<EditeProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();
  final _imageURIController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final isInit = true;
  var _exestingProduct = Product(
    id: null,
    description: '',
    title: '',
    imageUrl: '',
    price: 0,
  );
  var initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageURL': '',
  };
  var _isLoading = false;
  @override
  void initState() {
    _imageURIController.addListener(_updateImageFocusNode);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _exestingProduct =
            Provider.of<ProducstProvider>(context).findById(productId);

        initValue = {
          'title': _exestingProduct.title,
          'description': _exestingProduct.description,
          'price': _exestingProduct.price.toString(),
        };
        _imageURIController.text = _exestingProduct.imageUrl;
      }
    }
    super.didChangeDependencies();
  }

  void dispose() {
    _imageFocusNode.removeListener(_updateImageFocusNode);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageFocusNode.dispose();
    _imageURIController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_exestingProduct.id != null) {
      await Provider.of<ProducstProvider>(context, listen: false)
          .updateProduct(_exestingProduct.id, _exestingProduct);
    } else {
      try {
        await Provider.of<ProducstProvider>(context, listen: false)
            .addProduct(_exestingProduct);
      } catch (error) {
        showDialog<Null>(
            context: context,
            builder: (cnx) => AlertDialog(
                  title: Text(
                    'An error occurred',
                  ),
                  content: Text(
                    'Somthing went wrong!!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Okey',
                      ),
                    ),
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _updateImageFocusNode() {
    if (!_imageFocusNode.hasFocus) {
      if ((!_imageURIController.text.startsWith('http') &&
              !_imageURIController.text.startsWith('https')) ||
          !_imageURIController.text.endsWith('.jpg') &&
              !_imageURIController.text.endsWith('.jpeg') &&
              !_imageURIController.text.endsWith('.png')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edite product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(10),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValue['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _exestingProduct = Product(
                          id: _exestingProduct.id,
                          isFavorite: _exestingProduct.isFavorite,
                          description: _exestingProduct.description,
                          title: value,
                          imageUrl: _exestingProduct.imageUrl,
                          price: _exestingProduct.price,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please provide a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValue['price'],
                      decoration: InputDecoration(
                        labelText: 'price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _exestingProduct = Product(
                          id: _exestingProduct.id,
                          isFavorite: _exestingProduct.isFavorite,
                          description: _exestingProduct.description,
                          title: _exestingProduct.title,
                          imageUrl: _exestingProduct.imageUrl,
                          price: double.parse(value),
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please provide a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'please provide a valide number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'please enter a number more than zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValue['description'],
                      focusNode: _descriptionFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        _exestingProduct = Product(
                          id: _exestingProduct.id,
                          isFavorite: _exestingProduct.isFavorite,
                          description: value,
                          title: _exestingProduct.title,
                          imageUrl: _exestingProduct.imageUrl,
                          price: _exestingProduct.price,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please provide a description';
                        }
                        if (value.length < 10) {
                          return 'enter at least 10 character';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageURIController.text.isEmpty
                              ? Text(
                                  'Enter URL',
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageURIController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'ImageURL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageURIController,
                            focusNode: _imageFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _exestingProduct = Product(
                                id: _exestingProduct.id,
                                isFavorite: _exestingProduct.isFavorite,
                                description: _exestingProduct.description,
                                title: _exestingProduct.title,
                                imageUrl: value,
                                price: _exestingProduct.price,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
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
