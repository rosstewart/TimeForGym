import 'package:time_for_gym/split.dart';

class Activity {
  Activity(
      {required this.username,
      required this.type,
      required this.title,
      required this.description,
      required this.trainingDay,
      required this.millisecondsFromEpoch,
      required this.totalSecondsDuration,
      required this.usernamesThatLiked,
      required this.commentsFromEachUsername});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'type': type,
      'title': title,
      'description': description,
      'millisecondsFromEpoch': millisecondsFromEpoch,
      'totalSecondsDuration': totalSecondsDuration,
      'usernamesThatLiked': usernamesThatLiked,
      'commentsFromEachUsername': commentsFromEachUsername,
      'trainingDay': trainingDay?.toJson(),
    };
  }

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      username: json['username'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      millisecondsFromEpoch: json['millisecondsFromEpoch'],
      totalSecondsDuration: json['totalSecondsDuration'],
      usernamesThatLiked: List<String>.from(json['usernamesThatLiked']),
      commentsFromEachUsername:
          Map<String, List<String>>.from(json['commentsFromEachUsername']),
      trainingDay: json['trainingDay'] != null
          ? TrainingDay.fromJson(json['trainingDay'])
          : null, // Convert JSON to TrainingDay
    );
  }

  String username;
  String type; // Lift or Cardio or Pr
  String title;
  String description;
  TrainingDay? trainingDay;
  int millisecondsFromEpoch;
  int totalSecondsDuration;
  List<String> usernamesThatLiked;
  Map<String, List<String>> commentsFromEachUsername;
}
