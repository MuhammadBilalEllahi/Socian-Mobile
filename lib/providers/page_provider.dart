import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageIndexProvider = StateProvider<BottomNavBarRoute>((ref) => BottomNavBarRoute.home);
