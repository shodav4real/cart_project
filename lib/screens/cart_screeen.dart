import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    bool _isLoading = false;
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .color),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    /* FlatButton(
                      onPressed: () {
                        Provider.of<Orders>(context, listen: false).addOrder(
                          cart.items.values.toList(),
                          cart.totalAmount,
                        );
                        cart.clear();
                      },
                      child: Text(" ORDER NOW "),
                      textColor: Theme.of(context).primaryColor,
                    ) */
                    orderNowButton(cart: cart, isLoading: _isLoading),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (ctx, i) => CartItem(
                  cart.items.values.toList()[i].id,
                  //this is so we can the value from the list.
                  cart.items.keys.toList()[i],
                  cart.items.values.toList()[i].price,
                  cart.items.values.toList()[i].title,
                  cart.items.values.toList()[i].quantity,
                ),
                itemCount: cart.items.length,
              ),
            ),
          ],
        ));
  }
}

// ignore: must_be_immutable
class orderNowButton extends StatefulWidget {
  orderNowButton({
    Key key,
    @required this.cart,
    @required bool isLoading,
  })  : _isLoading = isLoading,
        super(key: key);

  final Cart cart;
  bool _isLoading;

  @override
  State<orderNowButton> createState() => _orderNowButtonState();
}

class _orderNowButtonState extends State<orderNowButton> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0 || widget._isLoading)
          ? null
          : () async {
              setState(() {
                widget._isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount,
                );
                widget.cart.clear();
                setState(() {
                  widget._isLoading = false;
                });
                /* Scaffold.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Order was added Successfully'),
                      duration: Duration(seconds: 4),
                      action: SnackBarAction(
                          label: "OK",
                          onPressed: () =>
                              Navigator.popAndPushNamed(context, 'orders'))),
                );
                Navigator.popAndPushNamed(context, 'orders');
               */
              } catch (e) {
                throw e;
              }
            },
      child:
          widget._isLoading ? CircularProgressIndicator() : Text(" ORDER NOW "),
      textColor: Theme.of(context).primaryColor,
    );
  }
}
