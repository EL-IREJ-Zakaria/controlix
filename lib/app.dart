import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/config_local_data_source.dart';
import 'data/datasources/local/history_local_data_source.dart';
import 'data/datasources/remote/chat_remote_data_source.dart';
import 'data/datasources/remote/task_remote_data_source.dart';
import 'data/repositories/app_settings_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/usecases/chat_usecases.dart';
import 'domain/usecases/history_usecases.dart';
import 'domain/usecases/settings_usecases.dart';
import 'domain/usecases/task_usecases.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/controllers/chat_controller.dart';
import 'presentation/controllers/task_controller.dart';
import 'presentation/screens/connect/connect_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

class ControlixBootstrapApp extends StatefulWidget {
  const ControlixBootstrapApp({super.key});

  @override
  State<ControlixBootstrapApp> createState() => _ControlixBootstrapAppState();
}

class _ControlixBootstrapAppState extends State<ControlixBootstrapApp> {
  late final Future<SharedPreferences> _sharedPreferencesFuture =
      SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _sharedPreferencesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ControlixApp(sharedPreferences: snapshot.data!);
        }

        return MaterialApp(
          title: 'Controlix',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class ControlixApp extends StatelessWidget {
  const ControlixApp({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    final apiClient = ApiClient(httpClient);

    final settingsRepository = AppSettingsRepositoryImpl(
      ConfigLocalDataSource(sharedPreferences),
    );
    final historyRepository = HistoryRepositoryImpl(
      HistoryLocalDataSource(sharedPreferences),
    );
    final taskRepository = TaskRepositoryImpl(TaskRemoteDataSource(apiClient));
    final chatRepository = ChatRepositoryImpl(ChatRemoteDataSource(apiClient));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppController(
            loadConnectionConfig: LoadConnectionConfigUseCase(
              settingsRepository,
            ),
            saveConnectionConfig: SaveConnectionConfigUseCase(
              settingsRepository,
            ),
            clearConnectionConfig: ClearConnectionConfigUseCase(
              settingsRepository,
            ),
            loadThemeMode: LoadThemeModeUseCase(settingsRepository),
            saveThemeMode: SaveThemeModeUseCase(settingsRepository),
          )..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskController(
            fetchTasks: FetchTasksUseCase(taskRepository),
            saveTask: SaveTaskUseCase(taskRepository),
            deleteTask: DeleteTaskUseCase(taskRepository),
            executeTask: ExecuteTaskUseCase(taskRepository),
            verifyConnection: VerifyConnectionUseCase(taskRepository),
            loadHistory: LoadHistoryUseCase(historyRepository),
            saveHistory: SaveHistoryUseCase(historyRepository),
            clearHistory: ClearHistoryUseCase(historyRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatController(
            sendChatMessage: SendChatMessageUseCase(chatRepository),
          )..bootstrap(),
        ),
      ],
      child: Consumer<AppController>(
        builder: (context, appController, _) {
          return MaterialApp(
            title: 'Controlix',
            debugShowCheckedModeBanner: false,
            themeMode: appController.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey<String>(
                  !appController.isReady
                      ? 'splash'
                      : appController.isConfigured
                      ? 'dashboard'
                      : 'connect',
                ),
                child: !appController.isReady
                    ? const SplashScreen()
                    : appController.isConfigured
                    ? const DashboardScreen()
                    : const ConnectScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
