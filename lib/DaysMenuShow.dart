import 'package:diyet_app/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'entities.dart';
import 'MenuDisplayItem.dart';
import 'Searchbar.dart';

class DaysMenuShow extends StatelessWidget {
  final MenuList menulist;
  const DaysMenuShow({Key? key, required this.menulist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawer(),
        body: Column(
          children: [
            AppBarWithNoSearch(),
            Expanded(
                child: MenuListWidget(
                    menulist: menulist, child: MenusDisplayView()))
          ],
        ),
      ),
    );
  }
}

class MenusDisplayView extends StatelessWidget {
  const MenusDisplayView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var menulist = MenuListWidget.of(context).menulist;
    return ListView.builder(
        itemCount: menulist.map.keys.length,
        itemBuilder: (context, index) {
          return MenuDisplayWidget(
            menu: menulist.getAt(index),
            canAddSubstract: false,
          );
        });
  }
}
