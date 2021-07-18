import 'dart:ui';

import 'package:diyet_app/CustomDrawer.dart';
import 'package:diyet_app/Searchbar.dart';
import 'package:flutter/material.dart';
import 'entities.dart';

const TextStyle _inputStyle = TextStyle(color: Colors.blue, fontSize: 16);

class EdibleAdd extends StatelessWidget {
  const EdibleAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: EdibleWidget(
      edible: Edible.empty,
      child: Scaffold(
        body: Column(children: [
          AppBarWithNoSearch(),
          Expanded(child: EdiblePorpertyHolderWidget())
        ]),
        drawer: CustomDrawer(),
        floatingActionButton: AddEdibleButton(),
      ),
    ));
  }
}

class OptionAddWidget extends StatelessWidget {
  final void Function() onPressed;
  const OptionAddWidget({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.blue, width: 1.6),
          borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        splashColor: Colors.transparent,
        onPressed: onPressed,
        icon: Icon(Icons.add_rounded, color: Colors.blue),
      ),
    );
  }
}

class EdiblePorpertyHolderWidget extends StatefulWidget {
  const EdiblePorpertyHolderWidget({Key? key}) : super(key: key);

  @override
  _EdiblePorpertyHolderWidgetState createState() =>
      _EdiblePorpertyHolderWidgetState();
}

class _EdiblePorpertyHolderWidgetState
    extends State<EdiblePorpertyHolderWidget> {
  final int maxOptionCount = 6;
  final List<List<TextEditingController>> optionTextEditingControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  final List<Widget> widgets = [];
  final TextEditingController nameController = TextEditingController();
  Widget _createOptionWidget() {
    var opt = Padding(
        padding: EdgeInsets.only(top: 15),
        child: OptionGetter(
          nameController: optionTextEditingControllers.last.first,
          calorieController: optionTextEditingControllers.last.last,
          onDelete:
              optionTextEditingControllers.length != 1 ? removeOption : null,
          index: widgets.length,
        ));
    optionTextEditingControllers
        .add([TextEditingController(), TextEditingController()]);
    return opt;
  }

  void removeOption(int index) {
    optionTextEditingControllers.length == maxOptionCount
        ? optionTextEditingControllers.removeAt(index - 1)
        : optionTextEditingControllers.removeAt(index - 2);
    setState(() {
      widgets.removeAt(index);
    });
  }

  void addOption() {
    if (optionTextEditingControllers.length < maxOptionCount) {
      setState(() {
        widgets.add(_createOptionWidget());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widgets.add(
      EdibleNameGetter(controller: nameController),
    );
    widgets.add(_createOptionWidget());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: optionTextEditingControllers.length < maxOptionCount
          ? widgets +
              <Widget>[
                OptionAddWidget(
                  onPressed: addOption,
                )
              ]
          : widgets,
    );
  }
}

class AddEdibleButton extends StatelessWidget {
  const AddEdibleButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IconButton(
          iconSize: 80,
          onPressed: () {
            print(EdibleWidget.of(context).edible);
          },
          icon: Icon(
            Icons.add_circle_outline_outlined,
            color: Colors.blue,
            size: 80,
          )),
    );
  }
}

class EdibleWidget extends InheritedWidget {
  final Edible edible;
  const EdibleWidget({required Widget child, required this.edible})
      : super(child: child);
  static EdibleWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType(aspect: EdibleWidget)!;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class OptionGetter extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController calorieController;
  final void Function(int)? onDelete;
  final int index;
  const OptionGetter(
      {Key? key,
      required this.nameController,
      required this.calorieController,
      required this.index,
      this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.blue, width: 1.6),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  maxLength: 16,
                  maxLines: 1,
                  controller: nameController,
                  decoration: InputDecoration(
                      hintText: 'Seçenek ismi',
                      hintStyle: TextStyle(color: Colors.lightBlue[300]),
                      prefixIcon: Icon(
                        Icons.settings_input_component,
                        color: Colors.blue,
                      )),
                  style: _inputStyle,
                ),
              ),
              Expanded(
                child: TextField(
                  maxLength: 6,
                  maxLines: 1,
                  controller: calorieController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      hintText: 'Kalori',
                      hintStyle: TextStyle(color: Colors.lightBlue[300]),
                      prefixIcon: Icon(
                        Icons.calculate_outlined,
                        color: Colors.blue,
                      )),
                  style: _inputStyle,
                ),
              ),
            ],
          ),
        ),
        if (onDelete != null)
          Positioned(
              right: -3,
              top: -10,
              child: IconButton(
                iconSize: 35,
                icon: Icon(
                  Icons.remove_circle_rounded,
                  color: Colors.blue,
                ),
                onPressed: () => this.onDelete!(index),
              )),
      ],
    );
  }
}

class EdibleNameGetter extends StatelessWidget {
  final TextEditingController controller;
  const EdibleNameGetter({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.blue, width: 1.6),
          borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        maxLength: 32,
        maxLines: 1,
        decoration: InputDecoration(
            hintText: 'Yiyeceğin ismi',
            hintStyle: TextStyle(color: Colors.lightBlue[300]),
            prefixIcon: Icon(
              Icons.food_bank,
              color: Colors.blue,
            )),
        style: _inputStyle,
      ),
    );
  }
}
