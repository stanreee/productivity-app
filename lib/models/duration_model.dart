import 'package:shared_preferences/shared_preferences.dart';

class DurationModel {

  int hours;
  int minutes;
  int seconds;

  DurationModel({ this.hours = 0, this.minutes = 0, this.seconds = 0 });

  @override
  String toString() {
    return '$hours hours $minutes minutes $seconds seconds';
  }

  String formatTime(value) {
    if(value < 10) return '0$value';
    return '$value';
  }

  String toStringAnalog() {
    return '${formatTime(hours)}:${formatTime(minutes)}:${formatTime(seconds)}';
  }

  bool isZeroTime() {
    return hours == 0 && minutes == 0 && seconds == 0;
  }

  int timeInSeconds() {
    return hours * 3600 + minutes * 60 + seconds;
  }

  void setTime(hours, minutes, seconds) {
    this.hours = hours;
    this.minutes = minutes;
    this.seconds = seconds;
  }

  void setTimeDurationModel(DurationModel model) {
    this.hours = model.hours;
    this.minutes = model.minutes;
    this.seconds = model.seconds;
  }

}