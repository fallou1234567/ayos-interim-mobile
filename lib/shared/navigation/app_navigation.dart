import 'package:flutter/foundation.dart';

class AppNavigation extends ChangeNotifier {
  int _currentTab = 0;
  int _missionsTab = 1;

  int get currentTab => _currentTab;
  int get missionsTab => _missionsTab;

  void openMissions({int tab = 0}) {
    _missionsTab = tab;
    _currentTab = 1;
    notifyListeners();
  }

  void selectTab(int index) {
    _currentTab = index;
    notifyListeners();
  }
}
