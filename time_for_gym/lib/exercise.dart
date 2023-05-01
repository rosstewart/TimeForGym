import 'package:flutter/material.dart';

class Exercise {
  const Exercise({
    required this.name,
    required this.description,
    required this.musclesWorked,
    required this.videoLink,
    required this.waitMultiplier,
  });

  @override
  String toString() {
    return name;
  }

  final String name, description, musclesWorked, videoLink;
  final double waitMultiplier;
}
