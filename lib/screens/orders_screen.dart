import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/app_drawer.dart';
import '../provider/orders.dart' show Orders;
import '../widget/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/order-screen';

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
        ),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).feachAndSetOrders(),
        builder: (cxt, dataSnapeShoot) {
          if (dataSnapeShoot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (dataSnapeShoot.error != null) {
            return Center(
              child: Text('There is an error'),
            );
          } else {
            return Consumer<Orders>(builder: (cxt, ordersData, child) {
              return ListView.builder(
                itemBuilder: (cxt, i) => OrderItem(
                  order: ordersData.orders[i],
                ),
                itemCount: ordersData.orders.length,
              );
            });
          }
        },
      ),
    );
  }
}
