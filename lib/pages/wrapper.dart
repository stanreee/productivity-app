import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loading/loading.dart';
import 'home/home.dart';
import 'welcome/welcome.dart';

class Wrapper extends StatelessWidget {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();



  Future<bool> _checkIfFirstUse() {
    Future<bool> _use = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('firsttime') ?? true);
    });
    return _use;
  }

  @override
  Widget build(BuildContext context) {
    // return home screen if not first time using, otherwise return welcome screen
    return new FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder:
        (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return LoadingScreen();
            default:
              if(!snapshot.hasError) {
                //TODO: make sure to make the welcome screen work
                return snapshot.data.getBool("firstOpen") != null ? Welcome() : Home();
              }else{
                return Wrapper();
              }
          }
        }
    );
  }
}