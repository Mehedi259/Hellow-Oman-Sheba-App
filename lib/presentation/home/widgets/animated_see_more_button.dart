import 'package:flutter/material.dart';

class AnimatedSeeMoreButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedSeeMoreButton({
    Key? key,
    required this.onPressed,
    this.text = 'আরও দেখুন',
  }) : super(key: key);

  @override
  State<AnimatedSeeMoreButton> createState() => _AnimatedSeeMoreButtonState();
}

class _AnimatedSeeMoreButtonState extends State<AnimatedSeeMoreButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.2, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0056D2).withOpacity(0.05), const Color(0xFF0056D2).withOpacity(0.1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0056D2).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: const Color(0xFF0056D2).withOpacity(0.2),
              highlightColor: const Color(0xFF0056D2).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0056D2), // Logo Blue
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return FractionalTranslation(
                          translation: _slideAnimation.value,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: const Color(0xFF0056D2), // Logo Blue
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
