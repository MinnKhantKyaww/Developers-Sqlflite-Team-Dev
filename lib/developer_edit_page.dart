import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlflite_app/repo/developer_repo.dart';
import 'model/developer.dart';

const languages = ["JAVA", "KOTLIN", "PYTHON", "SWIFT", "DART", "C++", "React Native"];

class DeveloperEditPage extends StatefulWidget {
  final DeveloperRepo repo;
  final Developer dev;

  const DeveloperEditPage({Key key, this.repo, this.dev}) : super(key: key);
  @override
  _DeveloperEditPageState createState() => _DeveloperEditPageState();
}

class _DeveloperEditPageState extends State<DeveloperEditPage> {
  TextEditingController _nameController;

  TextEditingController _ageController;

  String _heading;

  Widget _buildBottomSheet() {
    return InkWell(
      onTap: () {
        final controller = FixedExtentScrollController(
          initialItem: languages.indexOf(_heading),
        );
        final picker = Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16)))),
            child: CupertinoPicker.builder(
                scrollController: controller,
                itemExtent: 50,
                childCount: languages.length,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _heading = languages[index];
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      languages[index],
                    ),
                  );
                }));

        showModalBottomSheet(
            context: context,
            builder: (context) => picker,
            backgroundColor: Colors.transparent);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4))),
        child: Text(
          _heading,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildDropDown() {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton(
            value: _heading,
            isExpanded: true,
            items: languages.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: (e) {
              setState(() {
                _heading = e;
              });
            }),
      ),
    );
  }

  Widget _buildChoiceChip() {
    final pos = languages.indexOf(_heading);
    final controller = ScrollController(initialScrollOffset: pos * 50.0);

    return Container(
      height: 50,
      child: ListView.separated(
        itemCount: languages.length,
        controller: controller,
        itemBuilder: (context, index) {
          final selected = languages[index] == _heading;
          return ChoiceChip(
            label: Text(
              languages[index],
              style: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
            selected: selected,
            backgroundColor: Colors.grey,
            onSelected: (selected) {
              setState(() {
                _heading = languages[index];
              });
            },
            avatar: selected
                ? Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  )
                : null,
            selectedColor: Theme.of(context).primaryColor,
          );
        },
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 8,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.dev.name);
    _ageController = TextEditingController(text: "${widget.dev.age ?? ""}");
    _heading = widget.dev.heading ?? languages[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final widgets = [
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: "Name",
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Age",
          border: OutlineInputBorder(),
        ),
      ),
      _buildChoiceChip()
    ];

    if (widget.dev.id != null) {
      widgets.add(SizedBox(
        height: 16,
      ));
      widgets.add(RaisedButton(
        color: Color(0xffd50002),
        elevation: 0,
        padding: const EdgeInsets.all(16),
        onPressed: () {
          widget.repo.delete(widget.dev.id).whenComplete(() {
            Navigator.of(context).pop(true);
          });
        },
        child: Text(
          "DELETE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }

    final appBar = AppBar(
      title: Text(
        widget.dev.id == null ? "Create" : "Update",
      ),

      actions: [
        FlatButton(
            child: Text(
              "SAVE",
              style: TextStyle(color: Colors.white),
            ),
            shape: CircleBorder(),
            onPressed: () {
              if (widget.dev.id == null) {
                final d = Developer(
                    name: _nameController.text,
                    age: int.parse(_ageController.text),
                    heading: _heading);
                widget.repo.insert(d).whenComplete(() {
                  Navigator.of(context).pop(true);
                });
              } else {
                widget.repo
                    .update(Developer(
                        id: widget.dev.id,
                        name: _nameController.text,
                        age: int.parse(_ageController.text),
                        heading: _heading))
                    .whenComplete(() {
                  Navigator.of(context).pop(true);
                });
              }
            })
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }
}
