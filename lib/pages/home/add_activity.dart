import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:productivity_app/models/activity.dart';
import 'package:productivity_app/models/duration_model.dart';
import 'package:productivity_app/widgets/set_clock.dart';

class AddActivity extends StatefulWidget {

  final bool edit;
  final Activity activityToEdit;

  AddActivity({ Key key, this.edit = false, this.activityToEdit }): super (key: key);

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {

  String _activityName = '';

  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  int breakTime;
  
  int breakDuration_minutes = 0;
  int breakDuration_seconds = 10;

  bool _validate = false;
  bool _maxLength = false;

  String errorText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.edit) {
      hours = widget.activityToEdit.duration.hours;
      minutes = widget.activityToEdit.duration.minutes;
      seconds = widget.activityToEdit.duration.seconds;
      breakTime = widget.activityToEdit.breakInterval;
      _activityName = widget.activityToEdit.activityName;
    }
  }

  void createActivity(duration) {
    Activity activity = Activity(activityName: _activityName, duration: duration, breakInterval: breakTime, breakDuration: DurationModel(hours: 0, minutes: breakDuration_minutes, seconds: breakDuration_seconds));

    Navigator.pop(context, {
      'activity': activity,
    });
  }

  List<int> options = [5, 10, 15, 20, 25, 30];

  NumberPicker breakDurationMinutes, breakDurationSeconds;

  void _initializeBreakDurationPicker() {
    breakDurationMinutes = new NumberPicker.integer(
      initialValue: 0,
      minValue: 0,
      maxValue: 59,
      step: 1,
      infiniteLoop: true,
      onChanged: (value) {
        setState(() {
          breakDuration_minutes = value;
        });
      }
    );
    breakDurationSeconds = new NumberPicker.integer(
      initialValue: 10,
      minValue: 10,
      maxValue: 59,
      step: 1,
      infiniteLoop: true,
      onChanged: (value) {
        setState(() {
          breakDuration_seconds = value;
        });
      }
    );
  }

  _breakDurationDialog() async {
    _initializeBreakDurationPicker();
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text("Please set a break duration:"),
        content: Row(
          children: <Widget> [
            breakDurationMinutes,
            breakDurationSeconds,
          ],
        ),
        actions: <Widget> [
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Back'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              createActivity(DurationModel(hours: hours, minutes: minutes, seconds: seconds));
            },
            child: widget.edit ? Text('Save Changes') : Text('Create Activity'),
          ),
        ],
      ),
    ));
  }

  _intervalDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text("Please set a break interval:"),
        content: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                .map((e) => RadioListTile(
                  title: Text("$e minutes"),
                  value: e,
                  groupValue: breakTime,
                  selected: breakTime == e,
                  onChanged: (value) {
                    setState(() {
                      breakTime = value;
                    });
                  }
                ))
                .toList(),
            ),
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Back'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _breakDurationDialog();
            },
            child: Text('Next'),
          ),
        ],
      ), 
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: widget.edit ? Text ('Edit Activity') : Text('Create Activity'),
        centerTitle: true,
      ),
      body: _body()
    );
  }

  _body() {
    return Builder(
        builder: (context) => Container(
        child: _form(context),
      ),
    );
  }

  _form(context) {
    return Form(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              SetClock(parentWidget: this),
              SizedBox(height: 20),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), topLeft: Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: <Widget>[
                        _roundContainer(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _roundContainer(context) {
    return Row(
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              Text(
                'Activity Name (max 50 characters)',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: _activityName,
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
              SizedBox(height: 195.0),
              Center(
                child: RaisedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: widget.edit ? Text('Save Changes') : Text('Create activity'),
                  ),
                  onPressed: () async {
                    DurationModel duration;
                    setState(() {
                      _activityName.isEmpty ? (){_validate = true; errorText = 'Please enter an activity name.';}() : _validate = false;
                      _activityName.length > 50 ? (){_validate = true; errorText = 'Activity name exceeds maximum length.';}() : _maxLength = false;
                      duration = DurationModel(hours: hours, minutes: minutes, seconds: seconds);
                      if(duration.isZeroTime()) {
                        Scaffold.of(context)..removeCurrentSnackBar()..showSnackBar(SnackBar(content: Text("Please enter a valid duration.")));
                        return;
                      }
                    });
                    if(!_validate) { 
                      await _intervalDialog();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ), 
      ],
    );
  }
}