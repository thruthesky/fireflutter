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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuyAndSell'),
      ),
      body: PostListView(
        reverse: true,
        category: 'buyandsell',
        itemBuilder: (post, index) => PostBubble(post: post),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ForumChatInput(category: 'buyandsell'),
        ),
      ),
    );
  }
}
