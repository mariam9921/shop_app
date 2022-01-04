import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart' show Cart;
import '../widget/cart_item.dart';
import '../provider/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your cart',
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  FittedBox(
                    child: Chip(
                      label: Text(
                        '\$${cartData.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  OrderButton(cartData: cartData),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.cartItemCount,
              itemBuilder: (ctx, i) => CartItem(
                  id: cartData.items.values.toList()[i].id,
                  productId: cartData.items.keys.toList()[i],
                  title: cartData.items.values.toList()[i].title,
                  quantity: cartData.items.values.toList()[i].quantity,
                  price: cartData.items.values.toList()[i].price),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    @required this.cartData,
  });

  final Cart cartData;
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
    var _isLoading =false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading==true? CircularProgressIndicator() :Text(
        'ORDER NOW',
        style: TextStyle(
          // color: Theme.of(context).primaryColor,
        ),
      ),
      onPressed :( widget.cartData.totalAmount<=0 ||_isLoading==true) ? null: () async {
        setState(() {
         _isLoading=true;
        });

      await  Provider.of<Orders>(context, listen: false).addOrder(
            widget.cartData.items.values.toList(), widget.cartData.totalAmount);
  
   setState(() {
         _isLoading=false;
        });

        widget.cartData.clear();
      },
    );
  }
}
