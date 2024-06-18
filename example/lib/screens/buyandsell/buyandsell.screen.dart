import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BuyAndSellScreen extends StatefulWidget {
  static const String routeName = '/BuyAndSell';
  const BuyAndSellScreen({super.key});

  @override
  State<BuyAndSellScreen> createState() => _BuyAndSellScreenState();
}

class _BuyAndSellScreenState extends State<BuyAndSellScreen> {
  @override
  Widget build(BuildContext context) {
    return const ForumChatViewScreen(
        title: 'Buy And Sell', category: 'buyandsell');
  }
}
