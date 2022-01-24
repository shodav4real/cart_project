import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter_complete_guide/providers/product.dart';
import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  final String token;
  Orders(this.token, this._orders);
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [
      ..._orders
    ]; //this uses the spread operator to return a list of list.
  }

  Future<void> fetchAndSetOrders() async {
    final _authority =
        'https://cartproject2-default-rtdb.firebaseio.com/orders.json?auth=$token';
    final response = await http.get(
      Uri.parse(_authority),
    );
    final decodedOrder = json.decode(response.body) as Map<String, dynamic>;
    List<OrderItem> loadedOrder = [];
    if (decodedOrder == null) {
      return;
    }
    decodedOrder.forEach((orderId, orderDetails) {
      loadedOrder.add(
        OrderItem(
            id: orderId,
            amount: orderDetails['amount'],
            dateTime: DateTime.parse(orderDetails['dateTime']),
            products: (orderDetails['products'] as List<dynamic>)
                .map(
                  (prod) => CartItem(
                      id: prod['id'],
                      title: prod['title'],
                      price: prod['price'],
                      quantity: prod['quantity']),
                )
                .toList()),
      );
    });
    _orders = loadedOrder;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final _authority =
        'https://cartproject2-default-rtdb.firebaseio.com/orders.json?auth=$token';
    try {
      final response = await http.post(
        Uri.parse(
          _authority,
        ),
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity
                  })
              .toList()
        }),
      );
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: DateTime.now(),
            products: cartProducts),
      );
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }
}
