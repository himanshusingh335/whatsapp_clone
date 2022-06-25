import 'package:flutter/foundation.dart';

class IsLoading extends ChangeNotifier {
  bool isLoading = false;

  void changeToTrue() {
    isLoading = true;
    notifyListeners();
  }

  void changeToFalse() {
    isLoading = false;
    notifyListeners();
  }
}
