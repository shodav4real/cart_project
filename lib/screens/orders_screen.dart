// ignore: unused_import
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = 'orders';

  /* void initState() {
    Future.delayed(Duration.zero).then(
      (_) => Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
    );
    super.initState();
  }
 */
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    // final arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (BuildContext context, AsyncSnapshot dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(child: Text('Error Occurred!!!'));
            } else {
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                return ListView.builder(
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    itemCount: orderData.orders.length);
              });
            }
          }
        },
      ),
    );
  }
}
