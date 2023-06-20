import 'package:time_for_gym/exercise.dart';

class Gym {
  Gym({
    required this.name,
    required this.machinesAvailable,
    required this.resourcesAvailable,
  });

  @override
  String toString() {
    return name;
  }
  final String name;
  List<Exercise> machinesAvailable;
  Map<String, int> resourcesAvailable;

}