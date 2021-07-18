import 'dart:ui';

import 'package:diyet_app/CustomDrawer.dart';
import 'package:diyet_app/Searchbar.dart';
import 'package:flutter/material.dart';
import 'entities.dart';

const TextStyle _inputStyle = TextStyle(color: Colors.blue, fontSize: 16);

class EdibleAdd extends StatelessWidget {
  EdibleAdd({Key? key}) : super(key: key);
  final GlobalKey<_EdiblePorpertyHolderWidgetState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(children: [
        AppBarWithNoSearch(),
        Expanded(
            child: EdiblePorpertyHolderWidget(
          key: _key,
        ))
      ]),
      drawer: CustomDrawer(),
      floatingActionButton: AddEdibleButton(
        ediblePorpertyKey: _key,
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
    var opt = OptionGetter(
      nameController: optionTextEditingControllers.last.first,
      calorieController: optionTextEditingControllers.last.last,
      onDelete: optionTextEditingControllers.length != 1 ? removeOption : null,
    );
    optionTextEditingControllers
        .add([TextEditingController(), TextEditingController()]);
    return opt;
  }

  void removeOption(Widget x) {
    var index = widgets.indexOf(x);
    optionTextEditingControllers.removeAt(index - 1);
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

  Edible? getEdible() {
    var name = nameController.text;
    if (name.isEmpty) {
      setState(() {
        widgets.first = EdibleNameGetter(
          controller: nameController,
          hasError: true,
        );
      });

      return null;
    }
    var holder = OptionHolder.empty;
    bool error = false;

    for (int i = 0; i < optionTextEditingControllers.length - 1; i++) {
      var j = optionTextEditingControllers[i];
      if (j.first.text.isEmpty || j.last.text.isEmpty) {
        setState(() {
          widgets[i + 1] = OptionGetter(
            nameController: j.first,
            calorieController: j.last,
            errorState: true,
            onDelete: i > 0 ? removeOption : null,
          );
        });
        error = true;
      } else {
        holder.options.add(Option(j.first.text, double.parse(j.last.text), -1));
      }
    }
    if (!error) {
      return Edible(name, -1, holder);
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
  final GlobalKey<_EdiblePorpertyHolderWidgetState> ediblePorpertyKey;
  const AddEdibleButton({Key? key, required this.ediblePorpertyKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IconButton(
          iconSize: 80,
          onPressed: () {
            var edible = ediblePorpertyKey.currentState!.getEdible();
            print(edible);
          },
          icon: Icon(
            Icons.add_circle_outline_outlined,
            color: Colors.blue,
            size: 80,
          )),
    );
  }
}

class OptionGetter extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController calorieController;
  final void Function(Widget)? onDelete;
  final bool errorState;
  const OptionGetter(
      {Key? key,
      required this.nameController,
      required this.calorieController,
      this.onDelete,
      this.errorState = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Stack(
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
                        errorText: errorState
                            ? 'Hata! boş bırakılamaz!,silmeyi deneyin.'
                            : null,
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        errorText: errorState
                            ? 'Hata! boş bırakılamaz!,silmeyi deneyin.'
                            : null,
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
                  onPressed: () => this.onDelete!(this),
                )),
        ],
      ),
    );
  }
}

class EdibleNameGetter extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  const EdibleNameGetter(
      {Key? key, required this.controller, this.hasError = false})
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
            errorText: hasError ? 'Bu alan boş bırakılamaz' : null,
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
