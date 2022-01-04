import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.description,
    @required this.title,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  void _setFavoritValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggelFavoriteState(String authToken,String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://shop-app-1049c-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$authToken';

    try {
      final response = await http.put(
        url,
        body: json.encode(
           isFavorite,
          
        ),
      );
      if (response.statusCode >= 400) {
        _setFavoritValue(oldStatus);
      }
    } catch (error) {
      _setFavoritValue(oldStatus);
    }
  }
}
