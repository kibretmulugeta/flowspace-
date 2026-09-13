import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/local_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabaseService.instance.initialize();
  runApp(
    const ProviderScope(
      child: FlowSpaceApp(),
    ),
  );
}
