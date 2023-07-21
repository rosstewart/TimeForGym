import 'package:flutter/material.dart';
import 'package:time_for_gym/split.dart';

class Activity {
  Activity(
      {required this.username,
      required this.type,
      required this.title,
      required this.description,
      required this.trainingDay,
      required this.millisecondsFromEpoch,
      required this.totalMinutesDuration,
      required this.usernamesThatLiked,
      required this.commentsFromEachUsername,
      required this.pictureUrl,
      required this.picture});

  @override
  String toString() {
    return '$username - $title';
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'type': type,
      'title': title,
      'description': description,
      'millisecondsFromEpoch': millisecondsFromEpoch,
      'totalMinutesDuration': totalMinutesDuration,
      'usernamesThatLiked': usernamesThatLiked,
      'commentsFromEachUsername': commentsFromEachUsername,
      'trainingDay': trainingDay?.toJson(),
      'pictureUrl': pictureUrl,
    };
  }

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      username: json['username'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      millisecondsFromEpoch: json['millisecondsFromEpoch'],
      totalMinutesDuration: json['totalMinutesDuration'],
      usernamesThatLiked: List<String>.from(json['usernamesThatLiked']),
      commentsFromEachUsername: Map<String, List<String>>.from(
          (json['commentsFromEachUsername'] as Map<dynamic, dynamic>)
              .map((key, value) => MapEntry(key, value.cast<String>()))),
      trainingDay: json['trainingDay'] != null
          ? TrainingDay.fromJson(json['trainingDay'])
          : null, // Convert JSON to TrainingDay
      pictureUrl: json['pictureUrl'], // Could be null
      picture: json['pictureUrl'] != null ? Image.network(json['pictureUrl'], fit: BoxFit.cover): null
    );
  }

  String username;
  String type; // Lift or Cardio or Pr
  String title;
  String description;
  TrainingDay? trainingDay;
  int millisecondsFromEpoch;
  int totalMinutesDuration;
  List<String> usernamesThatLiked;
  Map<String, List<String>> commentsFromEachUsername;
  String? pictureUrl;
  Widget? picture;
}
