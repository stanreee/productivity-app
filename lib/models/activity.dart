

import 'dart:async';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:productivity_app/models/duration_model.dart';
import 'package:flutter/material.dart';

class Activity{

  String activityName;

  DurationModel duration;
  DurationModel breakDuration = new DurationModel(hours: 0, minutes: 0, seconds: 10);

  Activity({ this.activityName, this.duration, this.breakInterval, this.breakDuration });

  bool doing = false;
  bool paused = false;
  bool onBreak = false;

  bool distracted = false;

  int breakInterval;
  
}


class ActivityWidget extends StatefulWidget {
  final Activity activity;

  ActivityWidget({ Key key, this.activity }): super(key: key);

  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> with WidgetsBindingObserver {

  AppLifecycleState _notification;

  Activity activity;

  String _timerText;
  String _breakTimerText;
  String _distractedText;

  Timer _timer;
  Timer _breakTimer;
  Timer _distractedTimer;

  DurationModel _curDuration;
  DurationModel _curBreakTimer;
  DurationModel _distractedDuration;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    activity = widget.activity;
    _curDuration = new DurationModel(hours: activity.duration.hours, minutes: activity.duration.minutes, seconds: activity.duration.seconds);
    _curBreakTimer = new DurationModel(hours: 0, minutes: activity.breakInterval, seconds: 0);
    _distractedDuration = new DurationModel();
    _timerText = _curDuration.toStringAnalog();
    _breakTimerText = _curBreakTimer.toStringAnalog();
    _distractedText = _distractedDuration.toStringAnalog();
  }

  @override 
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        if(activity.distracted) {
          _distractedText = _distractedDuration.toStringAnalog();
          activity.distracted = false;
          _pauseTimer(_distractedTimer);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if(!activity.distracted && activity.doing){
          activity.distracted = true;
          _distractedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              _establishTimerConditions(true, _distractedDuration, timer, () {});
            });
          });
        } 
        break;
      default:
        break;
    }
  }

  // Establishes timer conditions for the specified DurationModel and Timer.
  // 'function' parameter is a function that is executed whenever the timer runs out.
  _establishTimerConditions(bool increasing, DurationModel durationModel, Timer timer, function) {
    if(!increasing) {
      if(durationModel.seconds > 0) {
        durationModel.seconds--;
      }else{
        if(durationModel.minutes > 0) {
          durationModel.minutes--;
        }else{
          if(durationModel.hours > 0) {
            durationModel.hours--;
            durationModel.minutes = 59;
          }else{
            timer.cancel();
            function();
            return;
          }
        }
        durationModel.seconds = 59;
      }
    }else{
      if(durationModel.seconds < 59) {
        durationModel.seconds++;
      }else{
        if(durationModel.minutes < 59) {
          durationModel.minutes++;
        }else{
          durationModel.hours++;
          durationModel.minutes = 0;
        }
        durationModel.seconds = 0;
      }
    }
  }

  _startBreak() {
    activity.onBreak = true;
    _pauseTimer(_timer);
    _curBreakTimer.setTimeDurationModel(activity.breakDuration);
    _breakTimerText = _curBreakTimer.toStringAnalog();

    _breakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _establishTimerConditions(false, _curBreakTimer, timer, () {
          _curBreakTimer.setTime(0, activity.breakInterval, 0);
          _breakTimerText = _curBreakTimer.toStringAnalog();
          activity.onBreak = false;
          _startDurationTimer();
        });
        _breakTimerText = _curBreakTimer.toStringAnalog();
      });
    });
  }

  _startDurationTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _establishTimerConditions(false, _curDuration, timer, () {
          _stopTimer();
        });
        _timerText = _curDuration.toStringAnalog();
      });
    });
    _breakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _establishTimerConditions(false, _curBreakTimer, timer, () {
          if(activity.doing) _startBreak();
        });
        _breakTimerText = _curBreakTimer.toStringAnalog();
      });
    });
  }

  _stopTimer() {
    _timer.cancel();
    _breakTimer.cancel();
    _distractedTimer.cancel();
    _curDuration.setTime(activity.duration.hours, activity.duration.minutes, activity.duration.seconds);
    _curBreakTimer.setTime(0, activity.breakInterval, 0);
    _distractedDuration.setTime(0, 0, 0);
    _timerText = activity.duration.toStringAnalog();
    _breakTimerText = _curBreakTimer.toStringAnalog();
    _distractedText = _distractedDuration.toStringAnalog();
    activity.paused = false;
    activity.doing = false;
    activity.onBreak = false;
    activity.distracted = false;
  }

  _pauseTimer(timer) {
    timer.cancel();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text("Cancel the timer?"),
        content: Text("Exiting out of this page will cancel the timer."),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              setState(() {
                _stopTimer();
              });
              Navigator.of(context).pop(true);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(activity.doing) {
          return _onWillPop();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(activity.activityName),
          backgroundColor: Colors.blue[200],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            CircularPercentIndicator(
              percent: activity.onBreak ? _curBreakTimer.timeInSeconds() / activity.breakDuration.timeInSeconds() : _curBreakTimer.timeInSeconds() / (activity.breakInterval * 60),
              animation: true,
              animateFromLastPercent: true,
              radius: 350.0,
              lineWidth: 20.0,
              progressColor: Colors.blue[300],
              backgroundColor: Colors.grey[300],
              center: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$_timerText',
                    style: TextStyle(
                      fontSize: 65,
                    ),
                  ),
                  Text(
                    activity.onBreak ? 'Time until break is over: $_breakTimerText' : 'Time until next break: $_breakTimerText',
                  ),
                  Text(
                    'Total time distracted: $_distractedText',
                  ),
                ],
              )
              
            ),
            SizedBox(height: 60.0),
            PlayPauseButtons(activity: activity, parentWidget: this),
            SizedBox(height: 10.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _curDuration.hours = 0;
                        _curDuration.minutes = 0;
                        _curDuration.seconds = 5;

                        _curBreakTimer.hours = 0;
                        _curBreakTimer.minutes = 0;
                        _curBreakTimer.seconds = 5;

                        _timerText = _curDuration.toStringAnalog();
                        _breakTimerText = _curBreakTimer.toStringAnalog();
                      });
                    },
                    child: Text('SET BOTH TIMERS TO 5s'),
                  ),
                  flex: 1
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _curBreakTimer.hours = 0;
                        _curBreakTimer.minutes = 0;
                        _curBreakTimer.seconds = 5;

                        _breakTimerText = _curBreakTimer.toStringAnalog();
                      });
                    },
                    child: Text('SET BREAK TIMER TO 5s'),
                  ),
                  flex: 1
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _curDuration.hours = 0;
                        _curDuration.minutes = 0;
                        _curDuration.seconds = 5;

                        _timerText = _curDuration.toStringAnalog();
                      });
                    },
                    child: Text('SET DURATION TIMER TO 5s'),
                  ),
                  flex: 1
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _curDuration.setTimeDurationModel(activity.duration);
                        _curBreakTimer.setTime(0, activity.breakInterval, 0);

                        _timerText = _curDuration.toStringAnalog();
                        _breakTimerText = _curBreakTimer.toStringAnalog();
                      });
                    },
                    child: Text('RESET'),
                  ),
                  flex: 1
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class PlayPauseButtons extends StatefulWidget {

  final Activity activity;
  final _ActivityWidgetState parentWidget;

  PlayPauseButtons({ this.activity, this.parentWidget });

  @override
  _PlayPauseButtonsState createState() => _PlayPauseButtonsState(activity: activity, parentWidget: parentWidget);
}

class _PlayPauseButtonsState extends State<PlayPauseButtons> {

  final Activity activity;
  final _ActivityWidgetState parentWidget;

  _PlayPauseButtonsState({ this.activity, this.parentWidget });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: RaisedButton(
              elevation: 2.0,
              color: activity.doing ? Colors.orangeAccent : Colors.grey,
              onPressed: activity.doing ? () {
                setState(() {
                  activity.paused = !activity.paused;
                  parentWidget.setState(() {
                    if(activity.paused) {
                      parentWidget._pauseTimer(parentWidget._timer);
                      parentWidget._pauseTimer(parentWidget._breakTimer);
                    }else{
                      parentWidget._startDurationTimer();
                    }
                  });
                });
              } : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: activity.paused ? Text("Resume Activity") : Text("Pause Activity"),
              ),
            ),// PAUSE BUTTON
          ),
          SizedBox(width: 4.0),
          Expanded(
            flex: 1,
            child: RaisedButton(
              elevation: 2.0,
              color: activity.doing ? Colors.redAccent : Colors.greenAccent,
              onPressed:() {
                setState(() {
                  activity.doing = !activity.doing;
                  parentWidget.setState(() {
                    if(activity.doing) {
                      parentWidget._startDurationTimer();
                    }else{
                      parentWidget._stopTimer();
                    }
                  });
                });
                //if(activity.doing) _startTimer;
                //else _stopTimer;
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: activity.doing ? Text("Stop Activity") : Text("Start Activity"),
              ),
            ),// START BUTTON
          ),
        ],
      ),
    );
  }
}

