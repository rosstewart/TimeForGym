import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/split.dart';
import 'package:time_for_gym/user.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  ProfilePage(this.user);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImageProvider<Object>? profilePictureProvider;
  // List to modify through different scopes
  final List<bool> isProfilePicLoading = [false];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      profilePictureProvider = widget.user!.profilePicture;
      if (profilePictureProvider == null &&
          widget.user!.profilePictureUrl != null) {
        // Retrieve from storage
        widget.user!.profilePicture =
            NetworkImage(widget.user!.profilePictureUrl!);
        profilePictureProvider = widget.user!.profilePicture;
      }
      // profilePictureProvider will remain null if no previous profile picture data
    }
  }

  void _dismissKeyboard(MyAppState appState) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Placeholder();
    }
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return GestureDetector(
      onTap: () {
        _dismissKeyboard(appState);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(widget.user!.username, style: titleStyle),
                if (widget.user!.userGymId.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Goes to ', style: greyLabelStyle),
                      GestureDetector(
                        onTap: () {
                          appState.currentGym =
                              appState.gyms[widget.user!.userGymId]!;
                          appState.changePage(9);
                          // GymPage(gym: appState.currentGym, isSelectedGym: appState.userGym == appState.gyms[widget.user!.userGymId]!);
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text(
                              appState.gyms[widget.user!.userGymId]!.name,
                              style: labelStyle.copyWith(
                                  color: theme.colorScheme.primary)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 50),
                  Column(
                    children: [
                      GestureDetector(
                        onTapDown: (tapDownDetails) {
                          showGalleryOrCameraMenu(
                              context, tapDownDetails.globalPosition);
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundImage: profilePictureProvider,
                              child: isProfilePicLoading[0]
                                  ? CircularProgressIndicator(
                                      color: theme.colorScheme.onBackground,
                                    )
                                  : (profilePictureProvider == null
                                      ? Icon(Icons.person,
                                          color: theme.colorScheme.onBackground)
                                      : null),
                            ),
                            // if (user.profilePicture != null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.add,
                                    color: theme.colorScheme.onBackground,
                                    size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Your Name', style: bodyStyle),
                    ],
                  ),
                  Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        appState.defaultProfileFollowersPage = true;
                        appState.changePage(12);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: [
                            Text('${widget.user!.followers.length}',
                                style: titleStyle),
                            Text('Followers',
                                style: titleStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        appState.defaultProfileFollowersPage = false;
                        appState.changePage(12);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          children: [
                            Text('${widget.user!.following.length}',
                                style: titleStyle),
                            Text('Following',
                                style: titleStyle.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65)))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: Text(
                    'DescriptionwirugheiruaeoifcjeirhgeuhfeugeigweoifgoueygveiruhfiuehargueuyDescriptionwirugheiruaeoifcjeirhgeuhfeugeigweoifgoueygveiruhfiuehargueuyDescriptionwirugheiruaeoifcjeirhgeuhfeugeigweoifgoueygveiruhfiuehargueuyDescriptionwirugheiruaeoifcjeirhgeuhfeugeigweoifgoueygveiruhfiuehargueuy',
                    maxLines: 3,
                    style: greyLabelStyle),
              ),
              SizedBox(height: 10),
              TabBar(
                unselectedLabelColor: theme.colorScheme.onBackground,
                tabs: [
                  Tab(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Icon(Icons.history, size: 20),
                        SizedBox(width: 10),
                        Text('Activity')
                      ])),
                  // Only if not current user's profile
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 20),
                        SizedBox(width: 10),
                        Text('Split')
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(children: [
                  Text('t'),
                  SplitPreview(widget.user!.splitJson != null
                      ? Split.fromJson(json.decode(widget.user!.splitJson!))
                      : null)
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showGalleryOrCameraMenu(BuildContext context, Offset tapPosition) {
    final theme = Theme.of(context);
    final labelStyle =
        TextStyle(color: theme.colorScheme.onBackground, fontSize: 10);
    // final RenderBox button = context.findRenderObject() as RenderBox;
    // final RenderBox overlay =
    //     Overlay.of(context).context.findRenderObject() as RenderBox;

    // final RelativeRect position = RelativeRect.fromRect(
    //   Rect.fromPoints(
    //     button.localToGlobal(button.size.bottomLeft(Offset.zero),
    //         ancestor: overlay),
    //     button.localToGlobal(button.size.bottomRight(Offset.zero),
    //         ancestor: overlay),
    //   ),
    //   Offset.zero & overlay.size,
    // );

    showMenu<String>(
      color: theme.colorScheme.primaryContainer,
      surfaceTintColor: theme.colorScheme.primaryContainer,
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'Choose from camera roll',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.photo_library,
                color: theme.colorScheme.primary, size: 14),
            title: Text('Choose from Camera roll', style: labelStyle),
          ),
        ),
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: 'Take a picture',
          child: ListTile(
            visualDensity: VisualDensity(
                vertical: VisualDensity.minimumDensity,
                horizontal: VisualDensity.minimumDensity),
            dense: true,
            leading: Icon(Icons.camera_alt,
                color: theme.colorScheme.primary, size: 14),
            title: Text('Take a picture', style: labelStyle),
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'Choose from camera roll') {
        await setProfilePicture(true);
      } else if (value == 'Take a picture') {
        await setProfilePicture(false);
      }
    });
  }

  Future<void> setProfilePicture(bool fromGallery) async {
    ImageProvider<Object>? imageProvider = await widget.user!
        .setProfilePicture(fromGallery, setState, isProfilePicLoading);
    if (imageProvider != null) {
      setState(() {
        profilePictureProvider = imageProvider;
      });
    }
    setState(() {
      isProfilePicLoading[0] = false;
    });
  }
}

class SplitPreview extends StatefulWidget {
  final Split? split;
  SplitPreview(this.split);
  @override
  State<SplitPreview> createState() => _SplitPreviewState();
}

class _SplitPreviewState extends State<SplitPreview> {
  final PageController _pageController = PageController();
  int _dotIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    if (widget.split == null) {
      return Column(children: [
        SizedBox(height: 20),
        Text(
          'No split saved',
          style: titleStyle.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(.65)),
        )
      ]);
    } else {
      return Column(children: [
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15)),
          height: 350,
          child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _dotIndex = index;
                });
              },
              children: List.generate(widget.split!.trainingDays.length,
                  (index) => SplitPreviewCard(widget.split!, index))),
        ),
        SizedBox(height: 10),
        DotsIndicator(
          onTap: (position) {
            setState(() {
              _pageController.animateToPage(position,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            });
          },
          key: Key('0'),
          dotsCount: widget.split!.trainingDays.length,
          position: _dotIndex,
          decorator: DotsDecorator(
            activeColor: theme.colorScheme.primary,
            size: const Size.square(8.0),
            activeSize: const Size.square(8.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ]);
    }
  }
}

class SplitPreviewCard extends StatelessWidget {
  final Split split;
  final int dayIndex;
  final List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  SplitPreviewCard(this.split, this.dayIndex);
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground);
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.8));
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weekdayNames[dayIndex]} - ',
                style: titleStyle,
              ),
              Text(split.trainingDays[dayIndex].splitDay,
                  style: titleStyle.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(.65)))
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: split.trainingDays[dayIndex].muscleGroups.length,
              itemBuilder: (context, index) {
                TrainingDay trainingDay = split.trainingDays[dayIndex];
                List<Exercise> exercisesTestList = appState
                    .muscleGroups[trainingDay.muscleGroups[index]]!
                    .where((element) =>
                        trainingDay.exerciseNames[index] == element.name)
                    .toList();
                if (exercisesTestList.length != 1) {
                  return null;
                }
                Exercise exercise = exercisesTestList[0];
                return Column(
                  children: [
                    if (trainingDay.isSupersettedWithLast[index])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_vert, color: theme.colorScheme.onBackground.withOpacity(.8), size: 16,),
                          Text(' Superset ', style: labelStyle),
                          Icon(Icons.swap_vert, color: theme.colorScheme.onBackground.withOpacity(.8), size: 16,),
                        ],
                      ),
                    ListTile(
                      onTap: () {
                        toExercise(appState, exercise);
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.onBackground),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ImageContainer(exerciseName: exercise.name),
                        ),
                      ),
                      title: Row(children: [
                        SizedBox(
                            width: 200,
                            child: Text(exercise.name,
                                style: labelStyle, maxLines: 2)),
                      ]),
                      subtitle: Row(
                        children: [
                          Text(
                            '${exercise.mainMuscleGroup} ',
                            style: labelStyle.copyWith(
                                color: theme.colorScheme.primary),
                          ),
                          if (exercise.mainMuscleGroup !=
                              exercise.musclesWorked[0])
                            Text(
                              '(${exercise.musclesWorked[0]})',
                              style: labelStyle.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(.65)),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${trainingDay.setsPerMuscleGroup[index]} sets',
                        style: greyLabelStyle,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void toExercise(MyAppState appState, Exercise exercise) {
    appState.currentExerciseFromProfilePage = exercise;
    appState.changePageToExercise(exercise);
  }
}
