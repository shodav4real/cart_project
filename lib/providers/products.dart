import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /* Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ), */
  ];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);
  List<Product> get items {
    /*//in a case of app wide filter
     if (_showFavoritesOnly) {
      return _items.where((item) => item.isFavorite).toList();
    } */
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

/*   // in a case of app wide filter
void showFavorites() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  } */

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final sfilterByUser =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var _authority =
        'https://cartproject2-default-rtdb.firebaseio.com/products.json?auth=$authToken&$sfilterByUser';
    print(_authority);
    try {
      //print('1');
      var request = await http.get(Uri.parse(_authority));
      //print(json.decode(request.body));
      final extratedData = json.decode(request.body) as Map<String, dynamic>;
      if (extratedData == null) {
        return;
      }
      final _FavAuthority =
          'https://cartproject2-default-rtdb.firebaseio.com/usersFavorites/$userId.json?auth=$authToken';
      final _favResponse = await http.get(Uri.parse(_FavAuthority));
      final _favResponseData = json.decode(_favResponse.body);

      final List<Product> loadedProduct = [];
      extratedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              isFavorite: _favResponseData == null
                  ? false
                  : _favResponseData[prodId] ?? false,
              price: prodData['price'],
              imageUrl: prodData['imageUrl']),
          /*
              //or 
               id: prodId,
            title: prodData.title.toString(),
            description: prodData.description.toString(),
            isFavorite: prodData.isFavorite,
            price: prodData.price,
            imageUrl: prodData.imageUrl)*/
        );
        _items = loadedProduct;
        notifyListeners();
      });
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(product) async {
    final _authority =
        'https://cartproject2-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    // const _unenocdedPath = '';
    try {
      final response = await http.post(
        Uri.parse(
          _authority,
          //     _unenocdedPath,
        ),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId ': userId
          // 'isFavorite': product.isFavorite
        }),
      );
      //print(json.decode(response.body) + ' line 97 prod');
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      _items.add(newProduct);
      //_item.insert(0,newProduct); //to add it at the beginning
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    // OPTIMISTICS UPDATING
    final _url =
        'https://cartproject2-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var _productData = _items[_existingProductIndex];
    _items.removeWhere((prod) => prod.id == id);
    //print('removed from ui');
    var response = await http.delete(Uri.parse(_url));
    print(response.statusCode);
    if (response.statusCode >= 400) {
      //print('failed to delete');
      _items.insert(_existingProductIndex, _productData);
      throw HttpException('Could not Delete the Item');
    }

    notifyListeners();
    _productData = null; //delete the pointer if the delete was successful
  }
  /*
  //Delete Method without the use of async and Await
    void deleteProduct(String id) {
      // OPTIMISTICS UPDATING
      final _url =
          'https://cart-project-6b3fc-default-rtdb.firebaseio.com/products/$id.json';

      final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
      var _productData = _items[_existingProductIndex];
      _items.removeWhere((prod) => prod.id == id);
      http.delete(Uri.parse(_url)).then((response) {
        if (response.statusCode >= 400) {
          throw HttpException('Could not Delet the Item');
        }
        _productData =
            null; //this is to delete the pointer in a case the delete was successful
      }).catchError((_) {
        _items.insert(_existingProductIndex,
            _productData); //this is to restore the item in a case the delete was not successful
      });
      notifyListeners();
    }
  */

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final exisitingProductIndex = _items.indexWhere((prod) => prod.id == id);
    if (exisitingProductIndex >= 0) {
      final _url =
          'https://cartproject2-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      //print(_url + ' url level');

      //this is used to update info on firebase
      var query = json.encode({
        'title': updatedProduct.title,
        'price': updatedProduct.price,
        'description': updatedProduct.description,
        'imageUrl': updatedProduct.imageUrl
      });
      await http.patch(Uri.parse(_url), body: query);
      //print(query + 'we dey patching');
      _items[exisitingProductIndex] = updatedProduct;
      notifyListeners();
    }
  }
}
