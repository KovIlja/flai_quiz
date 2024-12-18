import 'package:flutter/material.dart';

import 'utils/config.dart';
import 'entry_point.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Config.main();
  runApp(EntryPoint());
}
