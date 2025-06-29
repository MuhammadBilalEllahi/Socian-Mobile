import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/utils/constants.dart';

final pageIndexProvider =
    StateProvider<BottomNavBarRoute>((ref) => BottomNavBarRoute.home);
