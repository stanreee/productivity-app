import 'package:flutter/material.dart';
import 'package:productivity_app/models/activity.dart';
import 'package:productivity_app/models/duration_model.dart';
import 'package:productivity_app/widgets/set_clock.dart';

class EditActivity extends StatefulWidget {

  final Activity activity;

  EditActivity({ this.activity });

  @override
  _EditActivityState createState() => _EditActivityState(activity: activity);
}

class _EditActivityState extends State<EditActivity> {

  final Activity activity;

  _EditActivityState({ this.activity });

  String _activityName = '';

  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  bool _validate = false;
  bool _maxLength = false;

  String errorText = '';

  void editActivity(duration) {
    Activity activity = Activity(activityName: _activityName, duration: duration);

    Navigator.pop(context, {
      'activity': activity,
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activityName = activity.activityName;
    _hours = activity.duration.hours;
    _minutes = activity.duration.minutes;
    _seconds = activity.duration.seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: Text('Edit Activity'),
        centerTitle: true,
      ),
      body: Builder(
              builder: (context) => Container(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 10.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    'Activity Name (max 50 characters)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  TextFormField(
                    initialValue: activity.activityName,
                    onChanged: (val) {
                      setState(() {
                        _activityName = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'enter here',
                      errorText: _validate ? errorText : null,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Duration',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text('$_hours hours $_minutes minutes $_seconds seconds'),
                  SizedBox(height: 5.0),
                  RaisedButton(
                    child: Text('Set Duration'),
                    onPressed: () async {
                      dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SetClock()));
                      if(result != null && result['duration'] != null) {
                        setState(() {
                          _hours = result['duration'].hours;
                          _minutes = result['duration'].minutes;
                          _seconds = result['duration'].seconds;
                        });
                      }
                    }
                  ),
                  SizedBox(height: 10.0),
                  RaisedButton(
                    child: Text('Save activity'),
                    onPressed: () {
                      setState(() {
                        _activityName.isEmpty ? (){_validate = true; errorText = 'Please enter an activity name.';}() : _validate = false;
                        _activityName.length > 50 ? (){_validate = true; errorText = 'Activity name exceeds maximum length.';}() : _maxLength = false;
                        DurationModel duration = DurationModel(hours: _hours, minutes: _minutes, seconds: _seconds);
                        if(duration.isZeroTime()) {
                          Scaffold.of(context)..removeCurrentSnackBar()..showSnackBar(SnackBar(content: Text("Please enter a valid duration.")));
                          return;
                        }
                        if(!_validate) editActivity(duration);
                      });
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}