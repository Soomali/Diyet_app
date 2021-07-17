import 'dart:ui';

import 'package:diyet_app/storageManager.dart';
import 'package:flutter/material.dart';
import 'CustomDrawer.dart';
import 'Searchbar.dart';
import 'entities.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

double getPercent(num whole, num part) {
  return part * 100 / whole;
}

const Map<int, String> _monthMap = {
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};
String _toUserFriendlyString(DateTime date) {
  return '${date.day.toString()} ${_monthMap[date.month]!} ${date.year}';
}

class CalorieTrackingPage extends StatelessWidget {
  const CalorieTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawer(),
        body: Column(children: [
          AppBarWithNoSearch(),
          Expanded(child: ExpandableDayList())
        ]),
      ),
    );
  }
}

CircularProgressIndicator _getProgressIndicator(
    double sumCalories, double calorieNeed) {
  var color = Colors.blue;
  if (calorieNeed < sumCalories) {
    double val = getPercent(calorieNeed, sumCalories - calorieNeed) / 100;
    if (calorieNeed * 1.2 < sumCalories) {
      return CircularProgressIndicator(
        value: val,
        strokeWidth: 16,
        valueColor: AlwaysStoppedAnimation(Colors.red),
        backgroundColor: Colors.blue,
      );
    }
    return CircularProgressIndicator(
      value: val,
      strokeWidth: 16,
      valueColor: AlwaysStoppedAnimation(Colors.white),
      backgroundColor: Colors.blue,
    );
  } else if (calorieNeed * 0.8 > sumCalories) {
    color = Colors.red;
  }
  return CircularProgressIndicator(
    strokeWidth: 16,
    value: getPercent(calorieNeed, sumCalories) / 100,
    valueColor: AlwaysStoppedAnimation(color),
    backgroundColor: Colors.blueGrey,
  );
}

class TodaysCalories extends StatelessWidget {
  const TodaysCalories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StorageManager().getDayMenus(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Bağlantı yok');
            case ConnectionState.waiting:
              return Text('Bağlanılıyor..');
            case ConnectionState.active:
              return CircularProgressIndicator();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  'Hata oluştu,${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                );
              }
              if (snapshot.hasData) {
                var calorieNeed = PreferencesManager().userCalorieNeed;
                MenuList dayList = snapshot.data as MenuList;
                var indicator =
                    _getProgressIndicator(dayList.sumCalories, calorieNeed);
                return Row(
                  children: [
                    Expanded(
                      child: CalorieProgress(
                          indicator: indicator,
                          sumCalories: dayList.sumCalories),
                    ),
                    MenusShowWidget(menulist: dayList)
                  ],
                );
              }
              return CalorieProgress(
                  indicator: _getProgressIndicator(0, 2500), sumCalories: 0);
          }
        });
  }
}

class CalorieProgress extends StatelessWidget {
  const CalorieProgress({
    Key? key,
    required this.indicator,
    required this.sumCalories,
  }) : super(key: key);

  final CircularProgressIndicator indicator;
  final double sumCalories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.0,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: 200,
              height: 200,
              child: indicator,
            ),
          ),
          Center(
              child: Text(
            sumCalories.toStringAsFixed(1),
            style: TextStyle(color: Colors.blue, fontSize: 48),
          )),
        ],
      ),
    );
  }
}

class ExpandableDayList extends StatefulWidget {
  const ExpandableDayList({Key? key}) : super(key: key);

  @override
  _ExpandableDayListState createState() => _ExpandableDayListState();
}

class _ExpandableDayListState extends State<ExpandableDayList> {
  static const int _pageSize = 30;
  final manager = StorageManager();
  DateTime? startDate;
  final PagingController<int, MenuList> controller =
      PagingController(firstPageKey: 0);
  @override
  void initState() {
    controller.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await manager.getHistoricDayMenus(startDate: startDate);
      if (startDate == null) {
        startDate = DateTime.now().subtract(Duration(days: 31));
      } else {
        startDate = startDate!.subtract(Duration(days: 30));
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
      pagingController: this.controller,
      builderDelegate: PagedChildBuilderDelegate<MenuList>(
        itemBuilder: (context, menulist, index) => index == 0
            ? TodaysCalories()
            : ExpansionTile(
                title: Text(
                  _toUserFriendlyString(menulist.date),
                  style: TextStyle(color: Colors.blue),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CalorieProgress(
                            indicator: _getProgressIndicator(
                                menulist.sumCalories,
                                PreferencesManager().userCalorieNeed),
                            sumCalories: menulist.sumCalories),
                      ),
                      MenusShowWidget(
                        menulist: menulist,
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }
}

class MenusShowWidget extends StatelessWidget {
  final MenuList menulist;
  MenusShowWidget({Key? key, required this.menulist}) : super(key: key);

  final TextStyle _menusStyle = TextStyle(color: Colors.blue);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => print(menulist),
      child: Container(
        padding: EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
                  Expanded(
                    child: Text(''),
                  )
                ] +
                List.generate(
                    menulist.map.keys.length > 6 ? 6 : menulist.map.keys.length,
                    (index) {
                  if (index == 6 && menulist.map.keys.length > 6) {
                    return Text(
                      '...',
                      style: _menusStyle,
                    );
                  }
                  var menu = menulist.map.keys.elementAt(index);
                  var name = menu.name;
                  if (menu.name.length > 10)
                    name = menu.name.substring(0, 7) + '...';
                  return Text(
                    '$name  ${menulist[menu]}',
                    style: _menusStyle,
                  );
                }) +
                <Widget>[
                  Expanded(
                    child: Text(''),
                  )
                ],
          ),
        ),
      ),
    );
  }
}
