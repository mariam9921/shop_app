import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import './screens/cart_screen.dart';
import './provider/cart.dart';
import './screens/product_detailes_screen.dart';
import './provider/products_provider.dart';
import './provider/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edite_product_screen.dart';
import './provider/auth.dart';
import './screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (cxt) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProducstProvider>(
            update: (cxt, auth, previousProduct) => previousProduct
              ..updateUserAuth(
                  auth.token,
                  previousProduct == null ? [] : previousProduct.items,
                  auth.userId),
            create: (cxt) => ProducstProvider(),
          ),
          ChangeNotifierProvider(
            create: (cxt) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (cxt, auth, previousOrder) => previousOrder
              ..updateUserAuth(
                auth.token,
                auth.userId,
                previousOrder == null ? [] : previousOrder.orders,
              ),
            create: (cxt) => Orders(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (cxt, auth, _) {
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                primaryColor: Colors.purple,
                fontFamily: 'Lato',
                appBarTheme: AppBarTheme(
                  color: Colors.deepOrange,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: Colors.purple,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple,
                    
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.deepOrange,
                    ),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.deepOrange,
                  ),
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.deepOrange,
                ),
              ).copyWith(
                colorScheme: ThemeData().colorScheme.copyWith(
                      secondary: Colors.deepOrange,
                    ),
              ),
              home: auth.isAuth
                  ? ProductOverview()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (cxt, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthCard(),
                    ),
              routes: {
                ProductDetailesScreen.routeName: (cx) =>
                    ProductDetailesScreen(),
                CartScreen.routeName: (cx) => CartScreen(),
                OrdersScreen.routeName: (cx) => OrdersScreen(),
                UserProductScreen.routeNAme: (cx) => UserProductScreen(),
                EditeProductScreen.routeName: (cx) => EditeProductScreen(),
              },
            );
          },
        ));
  }
}
