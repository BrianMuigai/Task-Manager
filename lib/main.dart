import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:task/core/di/injector.dart';
import 'package:task/core/l10n/locale_provider.dart';
import 'package:task/core/observers/global_bloc_observer.dart';
import 'package:task/core/services/push_notification_service.dart';
import 'package:task/core/theme.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:task/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    await dotenv.load(fileName: "env/.env");
  } else {
    Bloc.observer = AppGlobalBlocObserver();
    await dotenv.load(fileName: "env/.dev.env");
  }
  await configureDependencies();
  final localeProvider = LocaleProvider();
  localeProvider.loadLocale();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize push notifications.
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  if (!kReleaseMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(ChangeNotifierProvider(
    create: (_) => localeProvider,
    child: App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                getIt<TasksBloc>()..add(SubscribeToTasksEvent())),
        BlocProvider(create: (context) => getIt<SettingsBloc>()),
        BlocProvider(
            create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()))
      ],
      child: MaterialApp(
        title: 'Task Manager (Clean Architecture with Bloc)',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        home: AuthWrapper(),
      ),
    );
  }
}
