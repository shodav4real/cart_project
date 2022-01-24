//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/products_overview_screen.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './providers/auth.dart';
import '../providers/orders.dart';
import '../providers/cart.dart';
import './screens/cart_screeen.dart';
//import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import '../screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import '../screens/edit_product_screen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          /* this suppplies a provider info that is needed in other providers
            e.g the authentication token is needed in all the providers
            so the changeNotifierProxyProvider needs an Auth as a dependency,
            product as whats provided and previousProduct as the version of the
            current Product objet prior to any update cos Product provider will
            reload on any change in Auth provider. previousProduct gives access 
            to other existing construtor to be passed after the new reload 
            If we required more deoendency
            there are other versions of ChangeNotifierProxyProvider as 2,3 to 6 */
          create: null,
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (ctx, auth, previousOrders) => Orders(
              auth.token, previousOrders == null ? [] : previousOrders.orders),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
            routes: {
              CartScreen.routeName: (ctx) => CartScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              /* AuthScreen.routeName: (ctx) => AuthScreen(),
                      ProductsOverviewScreen.routeName: (ctx) =>
                          ProductsOverviewScreen() */
            }),
      ),
    );
  }
}
