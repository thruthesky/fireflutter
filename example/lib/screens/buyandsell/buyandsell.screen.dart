import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BuyAndSellScreen extends StatefulWidget {
  static const String routeName = '/BuyAndSell';
  const BuyAndSellScreen({super.key});

  @override
  State<BuyAndSellScreen> createState() => _BuyAndSellScreenState();
}

class _BuyAndSellScreenState extends State<BuyAndSellScreen> {
  final initialOffset = 0.0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('BuyAndSell'),
      ),
      body: PostListView(
        controller: scrollController,
        reverse: true,
        category: 'buyandsell',
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
