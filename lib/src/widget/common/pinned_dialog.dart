import 'package:flutter/material.dart';

class PinnedDialog extends StatelessWidget {
  const PinnedDialog({
    super.key,
  });

  // final Widget pin;
  // final Widget content;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              clipBehavior: Clip.hardEdge,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  // This one is the base color
                  Colors.white,
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        // The shape of this one will be subtracted from the base color
                        backgroundBlendMode: BlendMode.dstOut,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    // This shapes the cutaway,
                    // must be slightly bigger to see the effect
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 40 + 10,
                        // So we will make it easy to modify the size of the cutaway
                        // that it will adjust automatically based on the formula below
                        //
                        // half minus a quarter plus the size of the cutaway
                        height: 20 - 5 + 10,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20 + 10),
                            bottomRight: Radius.circular(20 + 10),
                          ),
                          // ! the color here doesn't matter
                          // what matters is the size and shape
                          color: Colors.red,
                        ),
                        // color: Colors.red,
                        // Nothing should be added as a child
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 200,
              minHeight: 100,
            ),
            child: const Padding(
              // top padding must be the half of the height of the pin
              // in this case 20
              padding: EdgeInsets.only(top: 20),
              child: Padding(
                padding: EdgeInsets.all(14),
                // here we put the content
                child: Text('Pinned Dialog'),
              ),
            ),
          ),
          // This is the pin
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                // place the icon in the center
                child: const Icon(
                  Icons.push_pin,
                  // default size is 24
                  size: 24,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
