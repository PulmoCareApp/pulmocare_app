import 'package:flutter/material.dart';

class Article {
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.url,
  });
}
