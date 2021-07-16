import 'package:diyet_app/storageManager.dart';
import 'package:flutter/material.dart';
import 'CustomDrawer.dart';
import 'Searchbar.dart';
import 'entities.dart';

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
          Expanded(
            child: ListView(
              children: [TodaysCalories()],
            ),
          )
        ]),
      ),
    );
  }
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
                var color = Colors.blue;
                MenuList dayList = MenuList(
                  menus: snapshot.data as Map<Menu, int>,
                );

                if (calorieNeed < dayList.sumCalories) {
                  double val = dayList.sumCalories - calorieNeed;
                  if (calorieNeed * 1.2 < dayList.sumCalories) {
                    return CircularProgressIndicator(
                      value: val,
                      color: Colors.red,
                      backgroundColor: Colors.blue,
                    );
                  }
                  return CircularProgressIndicator(
                    value: val,
                    color: Colors.white,
                    backgroundColor: Colors.blue,
                  );
                } else if (calorieNeed * 0.8 > dayList.sumCalories) {
                  color = Colors.red;
                }

                return Container(
                  width: 300,
                  height: 300,
                  margin: EdgeInsets.only(top: 20),
                  child: FittedBox(
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          value: getPercent(calorieNeed, dayList.sumCalories) /
                              100,
                          valueColor: AlwaysStoppedAnimation(color),
                          backgroundColor: Colors.blueGrey,
                        ),
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
              return CircularProgressIndicator(
                value: 0,
                backgroundColor: Colors.blueGrey,
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
