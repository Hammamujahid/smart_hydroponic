import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final dashboardProvider =
    ChangeNotifierProvider<DashboardProvider>((ref) {
  return DashboardProvider();
});

class DashboardProvider extends ChangeNotifier {

}
