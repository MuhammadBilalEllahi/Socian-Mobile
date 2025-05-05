import 'package:flutter/material.dart';

class Cafe {
  final String id;
  final String name;
  final String status;
  final String information;
  final double accumulatedRating;
  final List<String> contact;
  final CafeAdmin attachedCafeAdmin;

  Cafe({
    required this.id,
    required this.name,
    required this.status,
    required this.information,
    required this.accumulatedRating,
    required this.contact,
    required this.attachedCafeAdmin,
  });

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      id: json['_id'],
      name: json['name'],
      status: json['status'],
      information: json['information'] ?? '',
      accumulatedRating: (json['accumulatedRating'] ?? 0).toDouble(),
      contact: List<String>.from(json['contact'] ?? []),
      attachedCafeAdmin: CafeAdmin.fromJson(json['attachedCafeAdmin']),
    );
  }
}

class CafeAdmin {
  final String id;
  final String name;
  final String email;

  CafeAdmin({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CafeAdmin.fromJson(Map<String, dynamic> json) {
    return CafeAdmin(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class FoodCategory {
  final String id;
  final String name;
  final String slug;

  FoodCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<double> price;
  final List<double> takeAwayPrice;
  final bool takeAwayStatus;
  final FoodCategory category;
  final bool bestSelling;
  final int favouritebByUsersCount;
  final int totalRatings;

  FoodItem(
      {required this.id,
      required this.name,
      required this.description,
      required this.imageUrl,
      required this.price,
      required this.takeAwayPrice,
      required this.takeAwayStatus,
      required this.category,
      required this.bestSelling,
      required this.favouritebByUsersCount,
      required this.totalRatings});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
        id: json['_id'],
        name: json['name'],
        description: json['description'],
        imageUrl: 'https://placehold.co/100'
        // json['imageUrl']
        ,
        price: List<double>.from(json['price'].map((e) => e.toDouble())),
        takeAwayPrice: List<double>.from(
            (json['takeAwayPrice'] ?? []).map((e) => e.toDouble())),
        takeAwayStatus: json['takeAwayStatus'] ?? false,
        category: FoodCategory.fromJson(json['category']),
        bestSelling: json['bestSelling'] ?? false,
        favouritebByUsersCount: (json['favouritebByUsersCount'] is int)
            ? json['favouritebByUsersCount']
            : 0,
        totalRatings:
            (json['totalRatings'] is int) ? json['totalRatings'] : 0.0);
  }
}
