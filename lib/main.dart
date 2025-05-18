import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_finance/app/app_module.dart';
import 'package:personal_finance/app/app_widget.dart';
import 'package:personal_finance/firebase_options.dart';

void main() async {
  await init();
  runApp(ModularApp(module: AppModule(), child: const App()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', 'default');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
