import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';

class SearchExercisesPage extends StatefulWidget {
  final List<Exercise> allExercises;

  SearchExercisesPage(this.allExercises);

  @override
  _SearchExercisesPageState createState() => _SearchExercisesPageState();
}

class _SearchExercisesPageState extends State<SearchExercisesPage> {
  String pattern = '';
  String selectedFilterOption = 'None';

  List<String> filterOptions = [
    'Dumbbell-Only',
    'No Equipment',
    'Machine-Only'
  ];

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    List<Exercise> filteredExercises = [];
    if (selectedFilterOption == 'Dumbbell-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Dumbbells');
        }
        return true;
      }).toList();
    } else if (selectedFilterOption == 'No Equipment') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('None') ||
              exercise.resourcesRequired!.contains('Pull-Up Bar') ||
              exercise.resourcesRequired!.contains('Parallel Bars');
        }
        return true;
      }).toList();
    } else if (selectedFilterOption == 'Machine-Only') {
      filteredExercises = widget.allExercises.where((exercise) {
        if (exercise.resourcesRequired != null) {
          return exercise.resourcesRequired!.contains('Machine');
        }
        return true;
      }).toList();
    } else {
      // No filter option
      filteredExercises = widget.allExercises;
    }

    List<Exercise> searchFilteredExercises;
    if (pattern.isNotEmpty) {
      searchFilteredExercises = filteredExercises
          .where((element) =>
              element.name.toLowerCase().contains(pattern.toLowerCase()) ||
              element.mainMuscleGroup
                  .toLowerCase()
                  .contains(pattern.toLowerCase()))
          .toList();
    } else {
      searchFilteredExercises = filteredExercises.toList();
    }

    return SwipeBack(
      swipe: true,
      appState: appState,
      index: 8, // Search page
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.background,
            title: // Search bar
                Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: theme.colorScheme.primaryContainer),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                      child: TextField(
                        focusNode: searchFocusNode,
                        autofocus: true,
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            // If value is empty, no search query
                            pattern = value;
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: searchFocusNode.hasFocus
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.65),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        pattern = '';
                                      });
                                      searchController
                                          .clear(); // Clear the text field
                                    },
                                  )
                                : null,
                            labelText: 'Search for an exercise or muscle group',
                            labelStyle: labelStyle.copyWith(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65)),
                            floatingLabelStyle: labelStyle.copyWith(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.65))),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    appState.changePage(8);
                  },
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Text('Cancel', style: labelStyle)),
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 5, // Buffer space from left
                    ),
                    ...filterOptions.map((option) {
                      bool isSelected = option == selectedFilterOption;
                      if (isSelected) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                scrollController.animateTo(
                                  0.0,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                if (!isSelected) {
                                  selectedFilterOption = option;
                                } else {
                                  selectedFilterOption = 'None';
                                }
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    resolveColor(theme.colorScheme.primary),
                                surfaceTintColor:
                                    resolveColor(theme.colorScheme.primary)),
                            label: Text(
                              option,
                              style: labelStyle,
                            ),
                            icon: Icon(Icons.cancel,
                                color: theme.colorScheme.onBackground,
                                size: 16),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                scrollController.animateTo(
                                  0.0,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                selectedFilterOption = option;
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor: resolveColor(
                                    theme.colorScheme.primaryContainer),
                                surfaceTintColor: resolveColor(
                                    theme.colorScheme.primaryContainer)),
                            child: Text(
                              option,
                              style: labelStyle,
                            ),
                          ),
                        );
                      }
                    }).toList(),
                    SizedBox(
                      width: 5, // Buffer space from right
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: searchFilteredExercises.length,
                  itemBuilder: (context, index) {
                    Exercise exercise = searchFilteredExercises[index];
                    return ListTile(
                      onTap: () {
                        // Search exercises page?
                        appState.fromSearchPage = true;
                        appState.changePageToExercise(exercise);
                      },
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.onBackground),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ImageContainer(exercise: exercise),
                        ),
                      ),
                      title: Row(children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            exercise.name,
                            style: labelStyle,
                            maxLines: 2,
                          ),
                        ),
                      ]),
                      subtitle: Text(
                        exercise.mainMuscleGroup,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.primary),
                        maxLines: 2,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
