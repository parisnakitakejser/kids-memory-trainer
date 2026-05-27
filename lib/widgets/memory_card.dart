import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';

class MemoryCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: card.isMatched,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: card.isMatched ? 1 : 0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.linear,
        builder: (context, matchValue, child) {
          final safeValue = matchValue.clamp(0.0, 1.0);
          final disappearValue = Curves.easeIn.transform(safeValue);
          final popValue = Curves.easeOutBack.transform(safeValue);
          final popScale = 1 + (sin(popValue * pi) * 0.18);
          final shrinkScale = 1 - (disappearValue * 0.92);
          final wobble = sin(safeValue * pi * 4) * 0.08 * (1 - safeValue);
          final opacity = (1 - disappearValue).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, -18 * disappearValue),
              child: Transform.rotate(
                angle: wobble,
                child: Transform.scale(
                  scale: popScale * shrinkScale,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22304A).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: TweenAnimationBuilder(
              tween: Tween<double>(
                  begin: 0, end: card.isFaceUp || card.isMatched ? 1 : 0),
              duration: const Duration(milliseconds: 400),
              builder: (context, double value, child) {
                bool isUnder = value > 0.5;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(value * pi),
                  alignment: Alignment.center,
                  child: isUnder
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                                color: card.color.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                )),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final symbolSize =
                                    (constraints.biggest.shortestSide * 0.62)
                                        .clamp(18.0, 64.0);

                                return Center(
                                  child: card.assetPath != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.asset(
                                            card.assetPath!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              );
                                            },
                                          ),
                                        )
                                      : card.content != null
                                          ? Text(
                                              card.content!,
                                              style: TextStyle(
                                                fontSize: symbolSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  )
                                                ],
                                              ),
                                            )
                                          : null,
                                );
                              },
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3F8CFF),
                                  Color(0xFF6BCEFF),
                                ]),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final iconSize =
                                  (constraints.biggest.shortestSide * 0.42)
                                      .clamp(16.0, 36.0);

                              return Center(
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Colors.white.withValues(alpha: 0.84),
                                  size: iconSize,
                                ),
                              );
                            },
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
