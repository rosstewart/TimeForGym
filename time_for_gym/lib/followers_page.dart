import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';
import 'package:time_for_gym/user.dart';

class FollowersPage extends StatefulWidget {
  final User? user;
  FollowersPage(this.user);
  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
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
    // final labelStyle = theme.textTheme.titleSmall!
    //     .copyWith(color: theme.colorScheme.onBackground);
    final greyLabelStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onBackground.withOpacity(.65));

    return GestureDetector(
      onTap: () {
        _dismissKeyboard(appState);
      },
      child: SwipeBack(
        appState: appState,
        index: 11,
        child: DefaultTabController(
          length: 2,
          initialIndex: appState.defaultProfileFollowersPage ? 0 : 1,
          child: Scaffold(
            appBar: AppBar(
              leading: Back(appState: appState, index: 11),
              leadingWidth: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: widget.user!.profilePicture,
                    child: widget.user!.profilePicture == null
                        ? Icon(Icons.person,
                            color: theme.colorScheme.onBackground)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.user!.username,
                    style: titleStyle,
                  ),
                  Spacer(flex: 2),
                ],
              ),
              bottom: TabBar(
                unselectedLabelColor: theme.colorScheme.onBackground,
                tabs: [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                ],
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            body:
                TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (widget.user!.following.isEmpty)
                      Text('No followers yet', style: greyLabelStyle),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (widget.user!.following.isEmpty)
                      Text('No following yet', style: greyLabelStyle),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
