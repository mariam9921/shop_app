import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  String _authToken;
  String _userId;
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  void updateUserAuth(String token, String userId,List orders){
     _authToken=token;
     _orders=orders;
     _userId=userId;

  }



  Future<void> feachAndSetOrders() async {
    final url =
        'https://shop-app-1049c-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
          date: DateTime.parse(orderData['date'])));
    });

    _orders=loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final time = DateTime.now();
    final url =
        'https://shop-app-1049c-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken';
    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'date': time.toIso8601String(),
          'products': products
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                },
              )
              .toList(),
        },
      ),
    );

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          date: time,
          products: products,
        ));
    notifyListeners();
  }
}
