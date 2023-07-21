import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/main.dart';

class FriendsPage extends StatefulWidget {
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onBackground);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.onBackground),
                  child: ListTile(
                    leading: Icon(
                      Icons.search,
                      color: theme.colorScheme.background,
                    ),
                    title: Text(
                      'Find friends',
                      style: TextStyle(
                          color: theme.colorScheme.background, fontSize: 16),
                    ),
                    onTap: () {
                      appState.changePage(14);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}