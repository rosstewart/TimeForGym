import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/activity.dart';
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
        .copyWith(color: theme.colorScheme.onBackground);
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
                  SizedBox(width: 30),
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
                    ],
                  ),
                  Spacer(),
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
                  SizedBox(width: 30),
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
                  SizedBox(width: 30),
                ],
              ),
              if (widget.user!.profileName.isNotEmpty) SizedBox(height: 10),
              if (widget.user!.profileName.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(widget.user!.profileName,
                      maxLines: 1, style: bodyStyle),
                ),
              if (widget.user!.profileDescription.isNotEmpty)
                SizedBox(height: 10),
              if (widget.user!.profileDescription.isNotEmpty)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(widget.user!.profileDescription,
                      maxLines: 3, style: greyLabelStyle),
                ),
              SizedBox(height: 10),
              Center(
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              resolveColor(theme.colorScheme.primaryContainer),
                          surfaceTintColor:
                              resolveColor(theme.colorScheme.primaryContainer)),
                      onPressed: () {
                        _showEditProfile(
                            context,
                            appState,
                            widget.user!.profileName,
                            widget.user!.profileDescription,
                            widget.user!,
                            setState);
                      },
                      child: Text(
                        'Edit Profile',
                        style: labelStyle,
                      ))),
              SizedBox(height: 3),
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
                  Column(
                    children: [
                      SizedBox(height: 20),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: resolveColor(
                                  theme.colorScheme.primaryContainer),
                              surfaceTintColor: resolveColor(
                                  theme.colorScheme.primaryContainer)),
                          onPressed: () {
                            _showAddManualActivity(
                                context, appState, widget.user!);
                          },
                          child: Text(
                            'Add Manual Activity',
                            style: labelStyle,
                          ))
                    ],
                  ),
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
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground);

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
          height: 325,
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
                          Icon(
                            Icons.swap_vert,
                            color:
                                theme.colorScheme.onBackground.withOpacity(.8),
                            size: 16,
                          ),
                          Text(' Superset ', style: labelStyle),
                          Icon(
                            Icons.swap_vert,
                            color:
                                theme.colorScheme.onBackground.withOpacity(.8),
                            size: 16,
                          ),
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

void _showEditProfile(
    BuildContext context,
    MyAppState appState,
    String previousName,
    String previousDescription,
    User user,
    StateSetter setProfilePageState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditProfileWindow(appState, previousName, previousDescription,
          user, setProfilePageState);
    },
  );
}

class EditProfileWindow extends StatefulWidget {
  final MyAppState appState;
  final String previousName;
  final String previousDescription;
  final User user;
  final StateSetter setProfilePageState;

  EditProfileWindow(this.appState, this.previousName, this.previousDescription,
      this.user, this.setProfilePageState);

  @override
  _EditProfileWindowState createState() => _EditProfileWindowState();
}

class _EditProfileWindowState extends State<EditProfileWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String? errorText;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _nameController = TextEditingController(text: widget.previousName);
    _descriptionController =
        TextEditingController(text: widget.previousDescription);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(width: 92, child: Text('Name', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _nameController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92,
                        child: Text('Description', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            maxLines: 2,
                            style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontSize: 12),
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _descriptionController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.length > 30) {
                        setState(() {
                          errorText = 'Name is over 30 characters';
                        });
                        return;
                      }
                      print(_descriptionController.text.length);
                      if (_descriptionController.text.length > 155) {
                        setState(() {
                          errorText = 'Description is over 155 characters';
                        });
                        return;
                      }
                      widget.setProfilePageState(() {
                        widget.user.profileName = _nameController.text;
                        widget.user.profileDescription =
                            _descriptionController.text;
                      });
                      appState.storeDataInFirestore();
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    child: Text('Done', style: labelStyle),
                  ),
                ),
                if (errorText != null) SizedBox(height: 5),
                if (errorText != null)
                  Center(
                    child: Text(errorText!,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.secondary)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddManualActivity(
    BuildContext context, MyAppState appState, User user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ManualActivityWindow(appState, user);
    },
  );
}

class ManualActivityWindow extends StatefulWidget {
  final MyAppState appState;
  final User user;

  ManualActivityWindow(this.appState, this.user);

  @override
  _ManualActivityWindowState createState() => _ManualActivityWindowState();
}

class _ManualActivityWindowState extends State<ManualActivityWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late TextEditingController _liftTitleController = TextEditingController();
  late TextEditingController _liftDescriptionController =
      TextEditingController();
  late TextEditingController _liftHoursController = TextEditingController();
  late TextEditingController _liftMinutesController = TextEditingController();

  String? errorText;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _animation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));
    final labelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: theme.colorScheme.onBackground)),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text('Add Manual Activity',
                      style: theme.textTheme.titleSmall!
                          .copyWith(color: theme.colorScheme.onBackground)),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(width: 92, child: Text('Title', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                            controller: _liftTitleController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _liftTitleController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92,
                        child: Text('Description', style: bodyStyle)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: TextField(
                            maxLines: 2,
                            style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontSize: 12),
                            controller: _liftDescriptionController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.65),
                                    size: 20),
                                onPressed: () {
                                  _liftDescriptionController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 92, child: Text('Duration', style: bodyStyle)),
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: theme.colorScheme.primaryContainer),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: TextField(
                                  maxLength: 2,
                                  style: TextStyle(
                                      color: theme.colorScheme.onBackground,
                                      fontSize: 12),
                                  controller: _liftHoursController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      labelText: '00',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelStyle: greyLabelStyle.copyWith(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.4))),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text('Hours',
                                style: greyLabelStyle.copyWith(fontSize: 9)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(' : ',
                                style: TextStyle(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(.65),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 17),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: theme.colorScheme.primaryContainer),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: TextField(
                                  maxLength: 2,
                                  style: TextStyle(
                                      color: theme.colorScheme.onBackground,
                                      fontSize: 12),
                                  controller: _liftMinutesController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      labelText: '00',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelStyle: greyLabelStyle.copyWith(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(.4))),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text('Minutes',
                                style: greyLabelStyle.copyWith(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_liftTitleController.text.isEmpty) {
                        setState(() {
                          errorText = 'Please enter a title';
                        });
                        return;
                      }
                      if (_liftTitleController.text.length > 150) {
                        setState(() {
                          errorText = 'Please enter a shorter title';
                        });
                        return;
                      }
                      if (_liftDescriptionController.text.length > 500) {
                        setState(() {
                          errorText = 'Description is too long';
                        });
                        return;
                      }
                      int hours, minutes;
                      if (_liftHoursController.text.isEmpty) {
                        hours = 0;
                      } else {
                        hours = int.parse(_liftHoursController.text);
                      }
                      if (_liftMinutesController.text.isEmpty) {
                        minutes = 0;
                      } else {
                        minutes = int.parse(_liftMinutesController.text);
                      }
                      if (minutes < 0 || minutes > 60 || hours < 0) {
                        setState(() {
                          errorText = 'Badly formatted duration';
                        });
                        return;
                      }
                      widget.user.activities.insert(
                          0,
                          Activity(
                              username: widget.user.username,
                              type: 'Manual',
                              title: _liftTitleController.text,
                              description: _liftDescriptionController.text,
                              trainingDay: null,
                              millisecondsFromEpoch:
                                  DateTime.now().millisecondsSinceEpoch,
                              totalSecondsDuration: minutes * 60,
                              usernamesThatLiked: [],
                              commentsFromEachUsername: {}));
                      appState.storeDataInFirestore();
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            resolveColor(theme.colorScheme.primary),
                        surfaceTintColor:
                            resolveColor(theme.colorScheme.primary)),
                    child: Text('Done', style: labelStyle),
                  ),
                ),
                if (errorText != null) SizedBox(height: 5),
                if (errorText != null)
                  Center(
                    child: Text(errorText!,
                        style: labelStyle.copyWith(
                            color: theme.colorScheme.secondary)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
