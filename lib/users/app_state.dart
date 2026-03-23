import 'package:flutter/foundation.dart';

class AppState {
  static final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  // HOME TAB SUBPAGE: false = HomeScreen, true = VenueScreen
  static final ValueNotifier<bool> isVenueSelected = ValueNotifier<bool>(false);
}