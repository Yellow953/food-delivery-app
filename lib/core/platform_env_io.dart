// IO implementation: read from Platform.environment.
import 'dart:io' show Platform;

String? environment(String key) => Platform.environment[key];
