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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: card.isFaceUp || card.isMatched ? 1 : 0),
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
                          color: card.isMatched ? card.color.withOpacity(0.3) : card.color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: card.isMatched ? Colors.white : Colors.white54,
                            width: card.isMatched ? 3 : 1,
                          )
                        ),
                        child: Center(
                          child: card.content != null
                              ? Text(
                                  card.content!,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blueGrey.shade600,
                            Colors.blueGrey.shade800,
                          ]
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.shade400, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white38,
                          size: 36,
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
