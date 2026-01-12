import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Enhanced Custom Page Transition
class CustomPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      children: [
        // Outgoing page with fade and scale
        if (secondaryAnimation.value > 0)
          FadeTransition(
            opacity: Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInCubic,
            )),
            child: Transform.scale(
              scale: 1.0 - (secondaryAnimation.value * 0.1),
              child: Container(), // Previous page content
            ),
          ),
        
        // Incoming page with fade and slide
        FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        ),
      ],
    );
  }
}

// Alternative: More advanced transition with blur effect
class BlurFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Page wrapper with animations
class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  
  const AnimatedPageWrapper({
    Key? key,
    required this.child,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Animated header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200))
                .slideX(begin: -0.2, duration: const Duration(milliseconds: 400)),
              ],
            ),
          ),
          
          // Content with staggered animation
          Expanded(
            child: child
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slideY(
                  begin: 0.05,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }
}