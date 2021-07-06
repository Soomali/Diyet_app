import 'package:flutter/material.dart';

class FuturePopUp<T> extends PopupRoute<T> {
  final Future<T> future;

  FuturePopUp({required this.future});
  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => "";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    this.future.then((T value) => Navigator.of(context).pop(value));

    Size size = MediaQuery.of(context).size;
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Center(
        child: Container(
            width: size.width * 0.6,
            height: size.height * 0.4,
            padding: EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              border: Border.all(color: Colors.blue, width: 0.6),
              borderRadius: BorderRadius.circular(9),
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 2.4,
              ),
            )),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}
