import 'package:flutter/material.dart';

/// 스택된 아바타(사진)
///
///
/// [children] 에는 [Avatar] 또는 [UserAvatar] 를 사용하면 된다. [children] 에 자식 위젯이 없으면
/// 빈 공간만 나타난다. 즉, 아무것도 나타나지 않는다.
///
/// [size] 는 크기를 나타내며, 가로/세로 동일한 크기이다. [children] 의 수에 따라서 가로 크기가 결정된다.
///
/// [borderWidth] 의 값이 0 이면 테두리가 없다. 기본값은 2 이다. 주의 할 것은, 테두리가 있으면 테두리의
/// 크기만큼 [size] 가 줄어든다. 예를 들어, [size] 가 48 이고, [borderWidth] 가 2 이면, 실제 child의
/// 크기는 44 가 되므로 적절하게 조절을 하여야 한다.
///
/// [leftFactor] 는 왼쪽으로 이동하는 정도를 나타내며, 0.5 를 기본값으로 한다. 0.5 는 [size] 의 절반만큼
/// 이동한다는 의미이다. 0.0 은 이동하지 않고, 1.0 은 [size] 의 크기만큼 이동한다. 0.2 로 하면, [size] 의
/// 20% 만큼 이동한다.
///
/// 주의, [StackedAvatar] 는 SizedBox 로 감싸서 최대 너비를 재한하고 있으므로, 가로 크기가 무제한으로
/// 늘어나지 않는다. 1 개이면 [size] 만큼, 2 개이면 [size] + [size] * [leftFactor] 만큼 커진다.
///
class StackedAvatar extends StatelessWidget {
  const StackedAvatar({
    super.key,
    required this.children,
    this.size = 48,
    this.radius = 20,
    this.borderWidth = 2,
    this.leftFactor = 0.5,
  });

  final List<Widget> children;
  final double size;
  final double radius;
  final double borderWidth;
  final double leftFactor;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: size + (children.length - 1) * size * leftFactor,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < children.length; i++)
            Positioned(
              left: i * size * leftFactor,
              child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Colors.white,
                      width: borderWidth,
                    ),
                  ),
                  child: children[i]),
            ),
        ],
      ),
    );
  }
}
