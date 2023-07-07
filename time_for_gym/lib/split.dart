// import 'dart:ffi';
import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:time_for_gym/exercise.dart';

class TrainingDay {
  List<String> muscleGroups = [];
  List<String> exerciseNames = [];
  List<String> exerciseIdentifiers = [];
  List<String> setNames = [];
  bool isNotRestDay = false;
  int dayOfWeek = -1;
  String splitDay = "Rest Day";
  List<int> setsPerMuscleGroup = [];

  TrainingDay(this.isNotRestDay, this.dayOfWeek);

  // TrainingDay.fromPref(this.muscleGroups,this.isNotRestDay,this.dayOfWeek);

  void addMuscleGroups(
      List<String> muscleGroupsToAdd,
      List<String> exerciseIdentifiersToAdd,
      List<String> setNamesToAdd,
      List<String> focusedMuscleGroups) {
    for (String focusedMuscleGroup in focusedMuscleGroups) {
      int focusedIndex = muscleGroupsToAdd.indexOf(focusedMuscleGroup);
      if (focusedIndex != -1) {
        muscleGroupsToAdd
            .removeAt(focusedIndex); // Move focused muscle groups to first
        String focusedIdentifier =
            exerciseIdentifiersToAdd.removeAt(focusedIndex);
        String focusedSetName = setNamesToAdd.removeAt(focusedIndex);
        muscleGroups.add(focusedMuscleGroup);
        exerciseIdentifiers.add(focusedIdentifier);
        setNames.add(focusedSetName);
      }
      // if (muscleGroupsToAdd.contains(focusedMuscleGroup)) {
      //   if (!muscleGroups.contains(focusedMuscleGroup)) {
      //     muscleGroups.add(focusedMuscleGroup);
      //   }
      //   muscleGroupsToAdd.remove(focusedMuscleGroup);
      // }
    }
    muscleGroups.addAll(muscleGroupsToAdd);
    exerciseIdentifiers.addAll(exerciseIdentifiersToAdd);
    setNames.addAll(setNamesToAdd);
  }

  void addPushA(List<String> focusedMuscleGroups) {
    // addMuscleGroups(
    //     ["Chest", "Chest", "Front Delts", "Side Delts", "Triceps"], focusedMuscleGroups);
    // splitDay = "Chest, Shoulders, & Triceps";
    addMuscleGroups([
      "Chest",
      "Chest",
      "Front Delts",
      "Side Delts",
      "Triceps"
    ], [
      "chestPress", // Mid
      "cableUpperChest", // Full
      "shoulderPressMachine", // Lengthened
      "dumbbellLateralRaise", // Shortened
      "cableTricepPushdown" // Shortened
    ], [
      "Mid/Lower Chest",
      "Upper Chest",
      "",
      "",
      "Triceps (Long Head)"
    ], focusedMuscleGroups);
    splitDay = "Push A";
  }

  void addPushB(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Chest",
      "Chest",
      "Front Delts",
      "Side Delts",
      "Triceps"
    ], [
      "upperChestPress", // Mid
      "cableLowerChest", // Full
      "cableFrontRaise", // Shortened
      "cableLateralRaise", // Lengthened
      "overheadTricep" // Lengthened
    ], [
      "Upper Chest",
      "Mid/Lower Chest",
      "",
      "",
      "Triceps (Lateral & Medial Head)"
    ], focusedMuscleGroups);
    splitDay = "Push B";
  }

  void addPullA(List<String> focusedMuscleGroups) {
    // addMuscleGroups(
    //     ["Back", "Biceps", "Rear Delts", "Abs"], focusedMuscleGroups);
    // splitDay = "Back & Biceps";
    addMuscleGroups([
      "Back",
      "Back",
      "Biceps",
      "Biceps",
      "Rear Delts",
      "Abs"
    ], [
      "latPulldown", // Shortened
      "chestSupportedUpperBackRow", // Full
      "hammerCurl", // Mid
      "longHeadCurl", // Lengthened
      "rearDelt", // Any
      "upperAbs"
    ], [
      "Lats",
      "Mid/Upper Back",
      "Biceps (Brachialis), Forearms",
      "Biceps (Long Head)",
      "",
      "Upper Abs",
    ], focusedMuscleGroups);
    splitDay = "Pull A";
  }

  void addPullB(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Back",
      "Back",
      "Biceps",
      "Biceps",
      "Rear Delts",
      "Abs"
    ], [
      "latPulldown", // Shortened
      "chestSupportedUpperBackRow", // Full
      "regularCurl", // Mid
      "shortHeadCurl", // Lengthened
      "rearDelt", // Any
      "lowerAbs"
    ], [
      "Lats",
      "Mid/Upper Back",
      "Overall Biceps",
      "Biceps (Short Head)",
      "",
      "Lower Abs",
    ], focusedMuscleGroups);
    splitDay = "Pull B";
  }

  void addLegsA(List<String> focusedMuscleGroups) {
    // addMuscleGroups(
    //     ["Glutes", "Quads", "Hamstrings", "Calves"], focusedMuscleGroups);
    // splitDay = "Legs";
    addMuscleGroups([
      "Glutes",
      "Glutes",
      "Hamstrings",
      "Quads",
      "Calves",
    ], [
      "gluteSquat", // Lengthened
      "gluteRDL", // Lengthened
      "seatedLegCurl", // Full
      "legExtension", // Full
      "calf", // Full
    ], [
      "Glutes & Quads",
      "",
      "",
      "",
      "",
    ], focusedMuscleGroups);
    splitDay = "Legs A";
  }

  void addLegsB(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Quads",
      "Quads",
      "Glutes",
      "Hamstrings",
      "Calves",
    ], [
      "quadSquat", // Lengthened
      "legExtension", // Lengthened
      "gluteRDL", // Full
      "seatedLegCurl", // Full
      "calf", // Full
    ], [
      "Quads & Glutes",
      "",
      "",
      "",
      "",
    ], focusedMuscleGroups);
    splitDay = "Legs B";
  }

  void addShoulders(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Front Delts",
      "Side Delts",
      "Rear Delts",
      "Abs"
    ], [
      "",
      "",
      "",
      "",
    ], [
      "",
      "",
      "",
      "",
    ], focusedMuscleGroups);
    splitDay = "Shoulders";
  }

  void addUpper1(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Chest",
      "Back",
      "Front Delts",
      "Side Delts",
      "Triceps",
      "Biceps",
      "Rear Delts"
    ], [
      "chestPress",
      "latPulldown",
      "shoulderPressMachine",
      "dumbbellLateralRaise",
      "cableTricepPushdown",
      "hammerCurl",
      "rearDelt",
    ], [
      "Mid/Lower Chest",
      "Lats",
      "",
      "",
      "Triceps (Long Head)",
      "Biceps (Brachialis), Forearms",
      "",
    ], focusedMuscleGroups);
    splitDay = "Upper Body A";
  }

  void addUpper2(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Chest",
      "Back",
      "Front Delts",
      "Side Delts",
      "Triceps",
      "Biceps",
      "Rear Delts"
    ], [
      "upperChestPress",
      "chestSupportedUpperBackRow",
      "cableFrontRaise",
      "cableLateralRaise",
      "overheadTricep",
      "regularCurl",
      "rearDelt",
    ], [
      "Upper Chest",
      "Mid/Upper Back",
      "",
      "",
      "Triceps (Lateral & Medial Head)",
      "Overall Biceps",
      "",
    ], focusedMuscleGroups);
    splitDay = "Upper Body B";
  }

  void addLower1(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Glutes",
      "Quads",
      "Hamstrings",
      "Calves",
      "Abs"
    ], [
      "gluteSquat", // Lengthened
      "legExtension", // Full
      "seatedLegCurl", // Full
      "calf", // Full
      "upperAbs"
    ], [
      "Glutes & Quads",
      "",
      "",
      "",
      "Upper Abs",
    ], focusedMuscleGroups);
    splitDay = "Lower Body A";
  }

  void addLower2(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Glutes",
      "Quads",
      "Hamstrings",
      "Calves",
      "Abs"
    ], [
      "gluteRDL", // Lengthened
      "quadSquat", // Full
      "seatedLegCurl", // Full
      "calf", // Full
      "lowerAbs"
    ], [
      "Quads & Glutes",
      "",
      "",
      "",
      "Lower Abs",
    ], focusedMuscleGroups);
    splitDay = "Lower Body B";
  }

  void addFullBody1(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Glutes",
      "Quads",
      "Chest",
      "Back",
      "Side Delts",
      "Biceps",
    ], [
      "gluteSquat",
      "legExtension",
      "chestPress",
      "latPulldown",
      "cableLateralRaise",
      "regularCurl",
    ], [
      "Glutes & Quads",
      "",
      "Mid/Lower Chest",
      "Lats",
      "",
      "Overall Biceps",
    ], focusedMuscleGroups);

    // addMuscleGroups(
    //     ["Chest", "Front Delts", "Side Delts", "Triceps", "Back", "Biceps", "Rear Delts", "Glutes", "Quads", "Hamstrings", "Calves", "Abs"], focusedMuscleGroups);
    // addUpper(focusedMuscleGroups);
    // addLower(focusedMuscleGroups);
    splitDay = "Full Body A"; // After the add calls to update splitDay
  }

  void addFullBody2(List<String> focusedMuscleGroups) {
    addMuscleGroups([
      "Front Delts",
      "Hamstrings",
      "Triceps",
      "Rear Delts",
      "Calves",
      "Abs"
    ], [
      "shoulderPressMachine",
      "seatedLegCurl",
      "cableTricepPushdown",
      "rearDelt",
      "calf",
      "lowerAbs", // Since Lower A has Upper Abs
    ], [
      "",
      "",
      "Triceps (Long Head)",
      "",
      "",
      "Lower Abs",
    ], focusedMuscleGroups);
    // addUpper(focusedMuscleGroups);
    // addLower(focusedMuscleGroups);
    splitDay = "Full Body B"; // After the add calls to update splitDay
  }

  void additionallyAddFocused(List<String> focusedMuscleGroups) {
    for (String focusedMuscleGroup in focusedMuscleGroups) {
      if (!muscleGroups.contains(focusedMuscleGroup)) {
        muscleGroups.add(focusedMuscleGroup);
        exerciseIdentifiers.add("");
        setNames.add("");
      }
    }
    int absIndex = muscleGroups.indexOf("Abs");
    if (absIndex != -1) {
      muscleGroups.removeAt(absIndex); // Move abs to end
      String absIdentifier = exerciseIdentifiers.removeAt(absIndex);
      String absSetName = setNames.removeAt(absIndex);
      muscleGroups.add("Abs");
      exerciseIdentifiers.add(absIdentifier);
      setNames.add(absSetName);
    }
  }

  // PLG - Push Pull Legs
  void addPLG(String char, List<String> focusedMuscleGroups) {
    switch (char) {
      // Push A
      case 'p':
      case 'P':
        addPushA(focusedMuscleGroups);
        if (char == "P") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      // Push B (Ran out of chars)
      case 'o':
      case 'O':
        addPushB(focusedMuscleGroups);
        if (char == "O") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 'l':
      case 'L':
        addPullA(focusedMuscleGroups);
        if (char == "L") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 'k':
      case 'K':
        addPullB(focusedMuscleGroups);
        if (char == "K") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 'g':
      case 'G':
        addLegsA(focusedMuscleGroups);
        if (char == "G") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 'h':
      case 'H':
        addLegsB(focusedMuscleGroups);
        if (char == "H") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 's':
      case 'S':
        addShoulders(focusedMuscleGroups);
        if (char == "S") {
          // Also focused
          additionallyAddFocused(focusedMuscleGroups);
          splitDay += " with Focused Muscle Groups";
        }
        break;
      case 'u':
        addUpper1(focusedMuscleGroups);
        break;
      case 'U':
        addUpper2(focusedMuscleGroups);
        break;
        // Remove focused muscle groups addition from upper and lower as it's too much volume
        // if (char == "U") {
        //   // Also focused
        //   additionallyAddFocused(focusedMuscleGroups);
        //   splitDay += " with Focused Muscle Groups";
        // }
      case 'w':
        addLower1(focusedMuscleGroups);
        break;
      case 'W':
        addLower2(focusedMuscleGroups);
        break;
        // Remove focused muscle groups addition from upper and lower as it's too much volume
        // if (char == "W") {
        //   // Also focused
        //   additionallyAddFocused(focusedMuscleGroups);
        //   splitDay += " with Focused Muscle Groups";
        // }
      case 'b':
        addFullBody1(focusedMuscleGroups);
        break;
      case 'B':
        addFullBody2(focusedMuscleGroups);
        break;
      // Remove focused muscle groups addition from upper and lower as it's too much volume
      // if (char == "B") {
      //   // Also focused
      //   additionallyAddFocused(focusedMuscleGroups);
      //   splitDay += " with Focused Muscle Groups";
      // }
      case 'f':
      case 'F':
        muscleGroups.addAll(focusedMuscleGroups);
        splitDay = "Focused Muscle Groups";
        break;
      default:
        print("ERROR - PLG");
        return;
    }
    exerciseNames = List.filled(muscleGroups.length, '');
  }

  @override
  String toString() {
    // if (isNotRestDay) {
    return splitDay; // - $muscleGroups";
    // }
    // return "Rest day";
  }

  // Convert the TrainingDay object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'muscleGroups': muscleGroups,
      'isNotRestDay': isNotRestDay,
      'dayOfWeek': dayOfWeek,
      'splitDay': splitDay,
      'setsPerMuscleGroup': setsPerMuscleGroup,
      'exerciseIdentifiers': exerciseIdentifiers,
      'setNames': setNames,
      'exerciseNames': exerciseNames,
    };
  }

  TrainingDay.fromJson(Map<String, dynamic> json) {
    muscleGroups = List<String>.from(json['muscleGroups'] ?? []);
    isNotRestDay = json['isNotRestDay'] ?? false;
    dayOfWeek = json['dayOfWeek'] ?? 0;
    splitDay = json['splitDay'] ?? "none";
    setsPerMuscleGroup = List<int>.from(json['setsPerMuscleGroup'] ?? []);
    exerciseIdentifiers = List<String>.from(json['exerciseIdentifiers'] ?? []);
    setNames = List<String>.from(json['setNames'] ?? []);
    exerciseNames = List<String>.from(json['exerciseNames'] ?? []);
  }

  void insertMuscleGroup(int index, String muscleGroup, int numSets,
      String identifier, String setName, String exerciseName) {
    muscleGroups.insert(index, muscleGroup);
    exerciseIdentifiers.insert(index, identifier);
    setNames.insert(index, setName);
    setsPerMuscleGroup.insert(index, numSets);
    exerciseNames.insert(index, exerciseName);
  }

  List<dynamic> removeMuscleGroup(int index) {
    List<dynamic> toReturn = [];
    toReturn.add(muscleGroups.removeAt(index));
    toReturn.add(setsPerMuscleGroup.removeAt(index));
    toReturn.add(exerciseIdentifiers.removeAt(index));
    toReturn.add(setNames.removeAt(index));
    toReturn.add(exerciseNames.removeAt(index));
    return toReturn;
  }

  TrainingDay._internal(
    this.muscleGroups,
    this.isNotRestDay,
    this.dayOfWeek,
    this.splitDay,
    this.setsPerMuscleGroup,
    this.exerciseIdentifiers,
    this.setNames,
    this.exerciseNames,
  );

  TrainingDay.deepCopy(TrainingDay original)
      : this._internal(
            List<String>.from(original.muscleGroups),
            original.isNotRestDay,
            original.dayOfWeek,
            original.splitDay,
            List<int>.from(original.setsPerMuscleGroup),
            List<String>.from(original.exerciseIdentifiers),
            List<String>.from(original.setNames),
            List<String>.from(original.exerciseNames));
}

class Split {
  String gymGoal = "";
  int trainingDaysPerWeek = 0;
  String trainingDaysInput = "";
  int trainingMinutesPerSession = -1;
  List<String> focusedMuscleGroups = [];
  List<TrainingDay> trainingDays = [];
  int equipmentLevel =
      2; // 2 for gym, 1 for dumbbell-only (& bodyweight), 0 for bodyweight-only

  List<String> pushMuscleGroups = [
    "Chest",
    "Triceps",
    "Front Delts",
    "Side Delts"
  ];
  List<String> pullMuscleGroups = ["Back", "Biceps", "Rear Delts", "Abs"];
  List<String> legsMuscleGroups = ["Quads", "Glutes", "Hamstrings", "Calves"];

  // 10-20 sets per week per muscle group
  // 10 minutes added per set per muscle group (~ 3 muscle groups per workout, ~ 3.33 minutes for each set)
  // 4 sets:  40 minutes
  // 6 sets:  1 hour
  // 10 sets: 1 hour 40 minutes
  // 15 sets: 2 hours 30 minutes
  // 20 sets: 3 hours 20 minutes

  // TODO:
  //    Import gym data, generate split for them based off free-weight exercises and machines available in gym & their popularity
  // Current:
  //    Generate split based off entire exercise library

  void addMuscleGroupsToTrainingDays(String plg, int startDay) {
    // Push = p, Pull = l, Legs = g, Rest = r
    // Days 0-6 (Monday - Sunday)
    int trainingDayIndex = 0;
    for (int i = 0; i < trainingDays.length; i++) {
      if (trainingDays[(i + startDay) % trainingDays.length].isNotRestDay) {
        trainingDays[(i + startDay) % trainingDays.length].addPLG(
            plg.substring(trainingDayIndex, trainingDayIndex + 1),
            focusedMuscleGroups);
        trainingDayIndex++;
      }
    }
  }

  void initializeNumSets() {
    for (TrainingDay trainingDay in trainingDays) {
      // 3 sets default per muscle group
      trainingDay.setsPerMuscleGroup =
          List.filled(trainingDay.muscleGroups.length, 3);
    }
  }

  // Check for valid inputs before calling constructor
  Split(this.gymGoal, this.trainingDaysInput, this.trainingMinutesPerSession,
      this.focusedMuscleGroups, this.equipmentLevel) {
    // trainingDaysPerWeek = trainingDaysInput.length;

    String focusedFlag;
    bool focusedDay = false;
    int splitStartDay = 0;

    int rCount = 0;
    int maxRCount = 0;
    for (int i = 0; i < trainingDaysInput.length; i++) {
      if (trainingDaysInput.substring(i, i + 1) == 'r') {
        // Rest day
        trainingDays.add(TrainingDay(false, i));

        rCount++;

        if (rCount > maxRCount) {
          // Start on day after most subsequent rest days
          maxRCount = rCount;
          splitStartDay = (i + 1) % trainingDaysInput.length;
        }
      } else {
        trainingDays.add(TrainingDay(true, i));
        trainingDaysPerWeek++;

        rCount = 0;
      }
    }

    if (focusedMuscleGroups.isEmpty) {
      focusedFlag = "none";
    } else {
      int numPushFocused = 0;
      int numPullFocused = 0;
      int numLegsFocused = 0;
      int maxFocused;

      for (String focusedMuscleGroup in focusedMuscleGroups) {
        if (pushMuscleGroups.contains(focusedMuscleGroup)) {
          numPushFocused++;
        } else if (pullMuscleGroups.contains(focusedMuscleGroup)) {
          numPullFocused++;
        } else {
          numLegsFocused++;
        }
      }

      maxFocused = max(max(numPushFocused, numPullFocused), numLegsFocused);
      if (maxFocused == numPushFocused) {
        focusedFlag = "push";
      } else if (maxFocused == numPullFocused) {
        focusedFlag = "pull";
      } else {
        focusedFlag = "legs";
      }
      if (maxFocused > 2) {
        focusedDay = true;
      }
    }

    switch (gymGoal) {
      case "Build Muscle":
        switch (trainingDaysPerWeek) {
          // Loop through and try different combinations to find the best one?
          case 1:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("b", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("b", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("f", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("b", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("f", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("b", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("f", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 2:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("bB", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("bB", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bf", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("bB", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bf", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("bB", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bf", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 3:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("uwb", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("uwb", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bBf", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("uwb", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bBf", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("wub", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("bBf", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 4:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("uwUW", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("uwUW", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("uwfb", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("uwUW", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("uwfb", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("wuWU", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("wufb", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 5:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("plguw", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("pgLwu", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("uwUWf", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("lgPwu", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("uwUWf", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("Lpguw", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("wuWUf", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 6:
            // o,k,h: push B, pull B, legs B
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("plgokh", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("plgokH", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("plguwf", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("lpgkoH", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("lpguwf", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("gplhoK", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("gplfuw", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          case 7:
            switch (focusedFlag) {
              case "none":
                addMuscleGroupsToTrainingDays("plgoksh", splitStartDay);
                break;
              case "push":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("plgokSh", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("plgokfh", splitStartDay);
                }
                break;
              case "pull":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("lpgkoSh", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("lpgkofh", splitStartDay);
                }
                break;
              case "legs":
                if (!focusedDay) {
                  addMuscleGroupsToTrainingDays("plgoSkh", splitStartDay);
                } else {
                  addMuscleGroupsToTrainingDays("plgofkh", splitStartDay);
                }
                break;
              default:
                print("ERROR - focused flag");
                return;
            }
            break;
          default:
            print("ERROR - training days per week");
            return;
        }
        initializeNumSets();
        break;
      case "Build Strength":
        break;
      case "Cardio-Focused":
        break;
      default:
        print("ERROR - gym goal");
        return;
    }
  }

  @override
  String toString() {
    return trainingDays.toString();
  }

  String toMuscleGroupString() {
    String s = "[";
    for (TrainingDay trainingDay in trainingDays) {
      s += "${trainingDay.muscleGroups},";
    }
    s = s.substring(0, s.length - 1); // remove last comma
    s += "]";

    return s;
  }

  // Split.fromPref();

  // Convert the Split object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'gymGoal': gymGoal,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'trainingDaysInput': trainingDaysInput,
      'trainingMinutesPerSession': trainingMinutesPerSession,
      'focusedMuscleGroups': focusedMuscleGroups,
      'trainingDays': trainingDays.map((day) => day.toJson()).toList(),
      'equipmentLevel': equipmentLevel,
    };
  }

  Split.fromJson(Map<String, dynamic> json) {
    gymGoal = json['gymGoal'] ?? "";
    trainingDaysPerWeek = json['trainingDaysPerWeek'] ?? 0;
    trainingDaysInput = json['trainingDaysInput'] ?? "";
    trainingMinutesPerSession = json['trainingMinutesPerSession'] ?? -1;
    focusedMuscleGroups = List<String>.from(json['focusedMuscleGroups'] ?? []);
    trainingDays = (json['trainingDays'] as List<dynamic>?)
            ?.map((day) => TrainingDay.fromJson(day))
            .toList() ??
        [];
    equipmentLevel = json['equipmentLevel'] ?? 2;
  }

  // void shift(int numDays){
  //   List<TrainingDay> temp = List<TrainingDay>.filled(7, TrainingDay(false, -1));
  //   for (int i = 0; i < trainingDays.length; i++){
  //     temp[(i + numDays) % trainingDays.length] = trainingDays[i];
  //     trainingDays[(i + numDays) % trainingDays.length] = trainingDays[i];
  //     temp = trainingDays[(i + 1 + numDays) % trainingDays.length];
  //   }
  // }

  void shift(int numDays) {
    int n = trainingDays.length;
    int k;

    if (numDays >= 0) {
      k = numDays % n;
    } else {
      k = (n - (-numDays % n)) % n;
    }

    reverse(0, n - 1);
    reverse(0, k - 1);
    reverse(k, n - 1);
  }

  void reverse(int start, int end) {
    while (start < end) {
      TrainingDay temp = trainingDays[start];
      trainingDays[start] = trainingDays[end];
      trainingDays[end] = temp;
      start++;
      end--;
    }
  }

  Split.deepCopy(Split other) {
    gymGoal = other.gymGoal;
    trainingDaysPerWeek = other.trainingDaysPerWeek;
    trainingDaysInput = other.trainingDaysInput;
    trainingMinutesPerSession = other.trainingMinutesPerSession;
    focusedMuscleGroups = List.from(other.focusedMuscleGroups);
    trainingDays =
        other.trainingDays.map((day) => TrainingDay.deepCopy(day)).toList();
    equipmentLevel = other.equipmentLevel;
  }
}


// void main() {
//   Split split =
//       Split("Build Muscle", "trtrrrt", 120, ["Side Delts", "Front Delts"]);

//   print(split);
//   split.shift(-2);
//   print(split);
  
// }
