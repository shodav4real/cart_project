import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../screens/cart_screeen.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

enum filterOptions {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/prodsOverview';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool showFavs = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // this wont work cos of(context) isnt available in the init class as the context has started except we put listen: false
    // Provider.of<Products>(context).fetchAndSetProducts();

    /*// this will also work to load things b4 other things gets loaded
     Future.delayed(Duration.zero)
    .then((value) => Provider.of<Products>(context).fetchAndSetProducts());
     */

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(false)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final allProducts = Provider.of<Products>(context, listen: false);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
              onSelected: (filterOptions selectedValue) {
                setState(() {
                  if (selectedValue == filterOptions.Favorite) {
                    return showFavs = true;
                  } else {
                    return showFavs = false;
                  }
                });
                /* // for app wide filter
                if (selectedValue == filterOptions.All) {
                  
                   allProducts.showAll();
                } else {
                 allProducts.showFavorites();
                } */
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favourites'),
                      value: filterOptions.Favorite,
                    ),
                    PopupMenuItem(
                      child: Text('Show All '),
                      value: filterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (
              _,
              cartData,
              ch,
            ) =>
                Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(showFavs),
    );
  }
}
