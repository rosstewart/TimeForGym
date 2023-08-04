import 'dart:async';

import 'package:time_for_gym/split.dart';

class ActiveWorkout {
  ActiveWorkout(
      {this.pageIndex = 0,
      required this.split,
      required this.trainingDay,
      required this.timeStarted,
      required this.dayIndex});

  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'millisecondsSinceEpoch': timeStarted.millisecondsSinceEpoch,
      'prMessages': prMessages,
      'dayIndex': dayIndex,
      'bannerTitles': bannerTitles,
      'bannerSubtitles': bannerSubtitles,
      'restTimesInSeconds': restTimesInSeconds,
      'timersSecondsLeft': timersSecondsLeft,
    };
  }

  static ActiveWorkout fromJson(Map<String, dynamic> json, Split split) {
    int dayIndex = json['dayIndex'];
    ActiveWorkout workout = ActiveWorkout(
      pageIndex: json['pageIndex'],
      split: split,
      dayIndex: dayIndex,
      trainingDay: split.trainingDays[dayIndex],
      timeStarted:
          DateTime.fromMillisecondsSinceEpoch(json['millisecondsSinceEpoch']),
    );
    workout.prMessages =
        Map<String, String>.from((json['prMessages'] as Map<dynamic, dynamic>));
    workout.areBannersAndTimersInitialized = true;
    List<dynamic> titleObjects = json['bannerTitles'];
    List<dynamic> subTitleObjects = json['bannerSubtitles'];
    List<dynamic> restTimesAsObjects = json['restTimesInSeconds'];
    List<dynamic> secondsLeftAsObjects = json['timersSecondsLeft'];
    workout.bannerTitles = titleObjects.cast<String>();
    workout.bannerSubtitles = subTitleObjects.cast<String>();
    workout.restTimesInSeconds = restTimesAsObjects.cast<int?>();
    workout.timersSecondsLeft = secondsLeftAsObjects.cast<int?>();
    workout.timers = List.filled(workout.bannerTitles.length, null);
    if (workout.bannerTitles.isNotEmpty) {
      workout.areBannersAndTimersInitialized = true;
    }
    return workout;
  }

  int pageIndex;
  Split split;
  TrainingDay trainingDay;
  DateTime timeStarted;
  Map<String, String> prMessages = {};
  int dayIndex;
  List<String> bannerTitles = [];
  List<String> bannerSubtitles = [];
  bool areBannersAndTimersInitialized = false;
  List<Timer?> timers = [];
  List<int?> restTimesInSeconds = [];
  List<int?> timersSecondsLeft = [];
  String? completionTitle;
  String? completionDescription;
  String? completionPostOption;
  String? completionImageErrorText;
  String? completionPickedFilePath;
  String? completionErrorText;
  DateTime? timeToCompleteTimer;
}
