import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlflite_app/developer_edit_page.dart';
import 'package:sqlflite_app/model/developer.dart';
import 'package:sqlflite_app/repo/developer_repo.dart';

const languages = [
  "JAVA",
  "KOTLIN",
  "PYTHON",
  "SWIFT",
  "DART",
  "C++",
  "React Native"
];

void main() {
  runApp(DeveloperApp());
}

class DeveloperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: _DevelopersPageState(
        repo: DeveloperRepo(),
      ),
    );
  }
}

class _DevelopersPageState extends StatefulWidget {
  final DeveloperRepo repo;

  const _DevelopersPageState({Key key, this.repo}) : super(key: key);

  @override
  __DevelopersPageStateState createState() => __DevelopersPageStateState();
}

class __DevelopersPageStateState extends State<_DevelopersPageState> {
  List<Developer> _lists;

  TextEditingController _searchController;

  String _heading;

  void findAllDevelopers({String name, String heading}) async {
    final list = await widget.repo.findAll(name: name, heading: _heading);
    setState(() {
      _lists = list;
    });
  }

  /*void insertRandom() async {
    final random = Random();
    var dev = Developer(
      name: "Dev ${_lists.length + 1}",
      heading: languages[random.nextInt(4)],
      age: random.nextInt(18),
    );

    */ /*await widget.repo.insert(dev);
    setState(() {
      findAllDevelopers();
    });*/ /*

    final result = await widget.repo.insert(dev);
    setState(() {
      _lists.add(result);
    });
  }*/

  void saveDeveloper(Developer dev) {
    final route = CupertinoPageRoute<bool>(
      builder: (context) => DeveloperEditPage(dev: dev, repo: widget.repo),
    );

    Navigator.push(context, route).then((result) {
      if (result) {
        findAllDevelopers();
      }
    });
  }

  void deleteDeveloper({int id, int index}) async {
    await widget.repo.delete(id);
    setState(() {
      _lists.removeAt(index);
    });
  }

  @override
  void initState() {
    _lists = List.empty(growable: true);

    _searchController = TextEditingController();
    findAllDevelopers();
    super.initState();
  }

  Widget _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: ShapeDecoration(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey,
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                findAllDevelopers(name: value);
              },
              cursorColor: Colors.black,
              decoration: InputDecoration.collapsed(
                hintText: "Search...",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      color: Colors.grey.shade50,
      height: 46,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: languages.length,
        itemBuilder: (context, index) {
          var selected = _heading == languages[index];
          return ChoiceChip(
            selected: selected,
            label: Text(languages[index],
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
            ),),
            selectedColor: Theme.of(context).primaryColor,
            onSelected: (selected) {
              _heading = selected ? languages[index] : null;
              findAllDevelopers(
                  name: _searchController.text, heading: _heading);
            },
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 8,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0,
      title: _buildSearchTextField(),
      bottom: PreferredSize(
        child: _buildFilterChip(),
        preferredSize: Size.fromHeight(45),
      ),
    );

    return Scaffold(
        appBar: appBar,
        body: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                indent: 16,
                height: 1,
              );
            },
            padding: EdgeInsets.all(8),
            itemCount: _lists.length,
            itemBuilder: (context, index) {
              final dev = _lists[index];

              return Dismissible(
                key: Key(dev.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onDismissed: (direction) {
                  deleteDeveloper(id: dev.id, index: index);
                },
                confirmDismiss: (direction) {
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("Are you sure want to delete?"),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text("NO"),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text("YES"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ListTile(
                  onTap: () {
                    showDialog<bool>(
                      context: context,
                      child: DeveloperEditPage(
                        dev: dev,
                        repo: widget.repo,
                      ),
                    ).then((result) {
                      findAllDevelopers();
                    });
                  },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueGrey[700],
                  ),
                  title: Text("${dev.name ?? "None"}"),
                  subtitle: Text("${dev.heading ?? "None"}"),
                  trailing: Text(dev.age.toString()),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveDeveloper(Developer());
          },
          child: Icon(Icons.add),
        ));
  }
}
