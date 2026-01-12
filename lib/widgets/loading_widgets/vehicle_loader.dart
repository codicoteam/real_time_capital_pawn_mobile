import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CardLoad extends StatelessWidget {
  const CardLoad({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: const CircleAvatar(),
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
