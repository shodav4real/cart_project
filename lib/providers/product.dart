import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void resetFavValue(OldState) {
    isFavorite = OldState;
    notifyListeners();
  }

  void toggleFavoriteStatus(String authToken, String userId) async {
    //the token was gotten from the loaction where toggleFavoriteStatus was
    //called in product_Item.dart. Although it can be sent as a constructor to
    //the entire Product class
    final OldFav = isFavorite;
    final _uri = Uri.parse(
        'https://cartproject2-default-rtdb.firebaseio.com/usersFavorites/$userId/$id.json?auth=$authToken');
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      var response = await http.put(_uri, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        resetFavValue(OldFav); //print('error in code');
      }
    } catch (e) {
      resetFavValue(OldFav);
    }
  }
}
