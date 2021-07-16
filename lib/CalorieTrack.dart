import 'package:diyet_app/storageManager.dart';
import 'package:flutter/material.dart';
import 'CustomDrawer.dart';
import 'Searchbar.dart';
import 'entities.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

double getPercent(num whole, num part) {
  return part * 100 / whole;
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
        valueColor: AlwaysStoppedAnimation(Colors.red),
        backgroundColor: Colors.blue,
      );
    }
    return CircularProgressIndicator(
      value: val,
      valueColor: AlwaysStoppedAnimation(Colors.white),
      backgroundColor: Colors.blue,
    );
  } else if (calorieNeed * 0.8 > sumCalories) {
    color = Colors.red;
  }
  return CircularProgressIndicator(
    strokeWidth: 2,
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
                return Container(
                  width: 300,
                  height: 300,
                  margin: EdgeInsets.only(top: 20),
                  child: FittedBox(
                    child: Stack(
                      children: [
                        indicator,
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.0158,
                              horizontal: MediaQuery.of(context).size.width *
                                  (0.018 +
                                      0.005 *
                                          (dayList.sumCalories
                                                  .toStringAsFixed(1)
                                                  .length -
                                              1))),
                          child: Text(
                            dayList.sumCalories.toString(),
                            style: TextStyle(color: Colors.blue, fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container(
                width: 300,
                height: 300,
                margin: EdgeInsets.only(top: 20),
                child: FittedBox(
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 0,
                        backgroundColor: Colors.grey,
                        strokeWidth: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.0158,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.028),
                        child: Text(
                          '0.0',
                          style: TextStyle(color: Colors.blue, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        });
    // return Column(
    //   children: [
    //     CircularProgressIndicator(value: StorageManager().,),
    //   ],
    // );
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
                  menulist.date.toString(),
                  style: TextStyle(color: Colors.blue),
                ),
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    margin: EdgeInsets.only(top: 20),
                    child: FittedBox(
                      child: Stack(
                        children: [
                          _getProgressIndicator(menulist.sumCalories,
                              PreferencesManager().userCalorieNeed),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.0158,
                                horizontal: MediaQuery.of(context).size.width *
                                    (0.018 +
                                        0.005 *
                                            (menulist.sumCalories
                                                    .toStringAsFixed(1)
                                                    .length -
                                                1))),
                            child: Text(
                              menulist.sumCalories.toString(),
                              style: TextStyle(color: Colors.blue, fontSize: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
