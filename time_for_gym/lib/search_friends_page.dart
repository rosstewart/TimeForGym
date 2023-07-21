import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_for_gym/exercise.dart';
import 'package:time_for_gym/main.dart';

// ignore: must_be_immutable
class SearchFriendsPage extends StatefulWidget {
  @override
  _SearchFriendsPageState createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage> {
  String pattern = '';

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

    List<String> filteredUsernames;
    if (pattern.isNotEmpty) {
      filteredUsernames = appState.allUsernames
          .where((element) =>
              element.toLowerCase().contains(pattern.toLowerCase()))
          .toList();
    } else {
      filteredUsernames = [];
    }

    return SwipeBack(
      appState: appState,
      index: 13,
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
                            labelText: 'Search',
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
                    appState.changePage(13);
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
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredUsernames.length,
                  itemBuilder: (context, index) {
                    String username = filteredUsernames[index];
                    return ListTile(
                      onTap: () {},
                      title: Text(
                        username,
                        style: labelStyle,
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
