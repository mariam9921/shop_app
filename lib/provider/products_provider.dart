import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './product.dart';

class ProducstProvider with ChangeNotifier {
  List<Product> _items = [];
  var _authToken;
  String _userId;

  void updateUserAuth(String token, List item, String userID) {
    _authToken = token;
    _items = item;
    _userId = userID;
  }

  List<Product> get items {
    return _items;
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  List<Product> get favorotItems {
    return _items.where((productItem) => productItem.isFavorite).toList();
  }

  Future<void> feachAndSetProducts([bool filterByUser = false]) async {
    var url;

    if (filterByUser) {
      url =
          'https://shop-app-1049c-default-rtdb.firebaseio.com/product.json?auth=$_authToken&orderBy="creatorid"&equalTo="$_userId"';
    } else {
      url =
          'https://shop-app-1049c-default-rtdb.firebaseio.com/product.json?auth=$_authToken';
    }

    try {
      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedData = [];
      if (extratedData == null) {
        return;
      }
      url =
          'https://shop-app-1049c-default-rtdb.firebaseio.com/userFavorite/$_userId.json?auth=$_authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extratedData.forEach((productId, productData) {
        loadedData.add(
          Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              imageUrl: productData['imageURL'],
              price: productData['price'],
              isFavorite: favoriteData == null
                  ? false
                  : favoriteData[productId] ?? false),
        );
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-1049c-default-rtdb.firebaseio.com/product.json?auth=$_authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageURL': product.imageUrl,
            'creatorid': _userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        description: product.description,
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((pro) => pro.id == id);
    if (productIndex >= 0) {
      final url =
          'https://shop-app-1049c-default-rtdb.firebaseio.com/product/$id.json?auth=$_authToken';
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageURL': newProduct.imageUrl,
          },
        ),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deletProduct(String id) async {
    final url =
        'https://shop-app-1049c-default-rtdb.firebaseio.com/product/$id.json?auth=$_authToken';
    final existingProductIndex = _items.indexWhere((pro) => pro.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeWhere((pro) => pro.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('could not delete product. ');
    }
    existingProduct = null;
  }
}
