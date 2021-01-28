import 'package:flutter/material.dart';
import 'package:productivity_app/models/activity.dart';
import 'package:productivity_app/pages/home/add_activity.dart';
import 'package:productivity_app/models/duration_model.dart';
import 'package:productivity_app/pages/home/edit_activity.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Activity> activityList = [
    Activity(activityName: 'piano', duration: DurationModel(hours: 2, minutes: 30, seconds: 0), breakInterval: 5, breakDuration: DurationModel(hours: 0, minutes: 0, seconds: 40)),
    Activity(activityName: 'study', duration: DurationModel(hours: 2, minutes: 30, seconds: 0), breakInterval: 5, breakDuration: DurationModel(hours: 0, minutes: 0, seconds: 40)),
  ];

  Future<void> editActivityAt(context, index) async {
    dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivity(edit: true, activityToEdit: activityList[index])));
                          
    if(result != null) {
      activityList.removeAt(index);
      activityList.insert(index, result['activity']);
      print(activityList.length);
      Scaffold.of(context)..removeCurrentSnackBar()..showSnackBar(SnackBar(content: Text('Activity saved.')));
    }
    setState((){});
  }

  Future<void> addActivity() async {
    dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivity()));
              
    if(result != null) {
      activityList.add(result['activity']);
      print(activityList.length);
    }
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        backgroundColor: Colors.blue[300],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add an activity',
            onPressed: () async {
              await addActivity();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: oldBody(),
    );
  }

  Widget oldBody() {
    return ListView.builder(
        itemCount: activityList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: () async {
                      dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityWidget(activity: activityList[index])));
                    },
                    title: Padding(
                      padding: const EdgeInsets.only(top:4.0),
                      child: Text(activityList[index].activityName),
                    ),
                    subtitle: Text(
                      "Duration: ${activityList[index].duration.toString()}\nBreak Interval: ${activityList[index].breakInterval} minutes\nBreak Duration: ${activityList[index].breakDuration.toString()}"
                      ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: const Text('Edit Activity'),
                        onPressed: () async {
                          await editActivityAt(context, index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      );
  }
}