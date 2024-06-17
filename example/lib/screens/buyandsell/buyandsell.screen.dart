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
    return Theme(
      data: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('BuyAndSell'),
        ),
        body: Stack(
          children: [
            PostListView(
              controller: scrollController,
              reverse: true,
              category: 'buyandsell',
              itemBuilder: (post, index) => PostBubble(post: post),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Theme(
                  data: ThemeData(
                    iconButtonTheme: IconButtonThemeData(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surface),
                        elevation: const WidgetStatePropertyAll(2),
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      scrollController.animateTo(
                        scrollController.position.minScrollExtent,
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          /// This is to display the Textfield above the keyboard
          /// viewInsets is a space that consumed by the keyboard
          /// and used as a padding of bottomNavigationBar
          padding: MediaQuery.of(context).viewInsets,
          child: const ForumChatInput(category: 'buyandsell'),
        ),
      ),
    );
  }
}
