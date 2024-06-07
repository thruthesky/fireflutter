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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('BuyAndSell'),
      ),
      body: PostListView(
        reverse: true,
        category: 'buyandsell',
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (post, index) => PostBubble(post: post),
      ),
      bottomNavigationBar: Padding(
        /// This is to display the Textfield above the keyboard
        /// viewInsets is a space that consumed by the keyboard
        /// and used as a padding of bottomNavigationBar
        padding: MediaQuery.of(context).viewInsets,
        child: const ForumChatInput(category: 'buyandsell'),
      ),
    );
  }
}
