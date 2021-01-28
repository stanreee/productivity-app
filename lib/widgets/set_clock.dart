import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:productivity_app/models/duration_model.dart';
import 'package:productivity_app/pages/home/add_activity.dart';

class SetClock extends StatefulWidget {

  final dynamic parentWidget;

  SetClock({ Key key, this.parentWidget }): super(key: key);

  @override
  _SetClockState createState() => _SetClockState();
}

class _SetClockState extends State<SetClock> {

  NumberPicker hoursNumberPicker;
  NumberPicker minutesNumberPicker;
  NumberPicker secondsNumberPicker;

  void updateDuration(duration) async {
    Navigator.pop(context, {
      'duration': duration,
    });
  }

  @override
  Widget build(BuildContext context) {
    _initializeNumberPickers();
    return Container(
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: <Widget>[
                    Text('hours', style: TextStyle(fontSize: 12.0)),
                    hoursNumberPicker,
                  ],
                ),
                SizedBox(width: 20.0),
                Column(
                  children: <Widget>[
                    Text('minutes', style: TextStyle(fontSize: 12.0)),
                    minutesNumberPicker,
                  ]
                ),
                SizedBox(width: 20.0),
                Column(
                  children: <Widget>[
                    Text('seconds', style: TextStyle(fontSize: 12.0)),
                    secondsNumberPicker,
                  ]
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _initializeNumberPickers() {
    hoursNumberPicker = new NumberPicker.integer(
      initialValue: widget.parentWidget.hours,
      minValue: 0,
      maxValue: 24,
      step: 1,
      infiniteLoop: true,
      onChanged: (value) {
        setState(() {
          widget.parentWidget.hours = value;
        });
      }
    );
    minutesNumberPicker = new NumberPicker.integer(
      initialValue: widget.parentWidget.minutes,
      minValue: 0,
      maxValue: 59,
      step: 1,
      infiniteLoop: true,
      onChanged: (value) => setState(() => widget.parentWidget.minutes = value),
    );
    secondsNumberPicker = new NumberPicker.integer(
      initialValue: widget.parentWidget.seconds,
      minValue: 0,
      maxValue: 59,
      step: 1,
      infiniteLoop: true,
      onChanged: (value) => setState(() => widget.parentWidget.seconds = value),
    );
  }
}