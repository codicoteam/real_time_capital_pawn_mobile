import 'package:flutter/material.dart';
import 'package:real_time_pawn/features/test/circular_container.dart';
import 'package:real_time_pawn/features/test/curved_edges_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Fixed: added parentheses around super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TCurvedEdgeWidget(
              child: Container(
                color: Colors.indigoAccent, // Added missing comma
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -150,
                        right: -250,
                        child: TCircularContainer(
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        right: -300,
                        child: TCircularContainer(
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
