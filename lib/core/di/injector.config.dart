// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/reset_password.dart' as _i1066;
import '../../features/auth/domain/usecases/sign_in_with_email_password.dart'
    as _i466;
import '../../features/auth/domain/usecases/sign_in_with_google.dart' as _i692;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/tasks/data/datasources/firebase_task_datasource.dart'
    as _i873;
import '../../features/tasks/data/repositories/task_repository_impl.dart'
    as _i20;
import '../../features/tasks/domain/repositories/task_repository.dart' as _i148;
import '../../features/tasks/domain/usecases/add_task.dart' as _i793;
import '../../features/tasks/domain/usecases/delete_task.dart' as _i840;
import '../../features/tasks/domain/usecases/get_tasks.dart' as _i517;
import '../../features/tasks/domain/usecases/update_task.dart' as _i739;
import '../../features/tasks/presentation/bloc/tasks_bloc.dart' as _i447;
import '../shared_preferences_manager.dart' as _i178;
import 'module_injector.dart' as _i759;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModules = _$RegisterModules();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModules.prefs(),
      preResolve: true,
    );
    gh.lazySingleton<_i873.FirebaseTaskDataSource>(
        () => _i873.FirebaseTaskDataSource());
    gh.lazySingleton<_i148.TaskRepository>(() => _i20.TaskRepositoryImpl(
        dataSource: gh<_i873.FirebaseTaskDataSource>()));
    gh.factory<_i974.FirebaseFirestore>(
      () => registerModules.firebaseDatabase,
      instanceName: 'firebaseDatabase',
    );
    gh.factory<_i59.FirebaseAuth>(
      () => registerModules.firebaseAuth,
      instanceName: 'firebaseAuth',
    );
    gh.factory<_i116.GoogleSignIn>(
      () => registerModules.googleSignIn,
      instanceName: 'googleSignIn',
    );
    gh.lazySingleton<_i178.SharedPreferencesManager>(
        () => _i178.SharedPreferencesManager(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i517.GetTasks>(
        () => _i517.GetTasks(gh<_i148.TaskRepository>()));
    gh.lazySingleton<_i517.GetTasksStream>(
        () => _i517.GetTasksStream(gh<_i148.TaskRepository>()));
    gh.lazySingleton<_i793.AddTask>(
        () => _i793.AddTask(gh<_i148.TaskRepository>()));
    gh.lazySingleton<_i739.UpdateTask>(
        () => _i739.UpdateTask(gh<_i148.TaskRepository>()));
    gh.lazySingleton<_i840.DeleteTask>(
        () => _i840.DeleteTask(gh<_i148.TaskRepository>()));
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i59.FirebaseAuth>(instanceName: 'firebaseAuth'),
          gh<_i116.GoogleSignIn>(instanceName: 'googleSignIn'),
        ));
    gh.lazySingleton<_i692.SignInWithGoogle>(
        () => _i692.SignInWithGoogle(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i466.SignInWithEmailPassword>(
        () => _i466.SignInWithEmailPassword(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i1066.ResetPassword>(
        () => _i1066.ResetPassword(gh<_i787.AuthRepository>()));
    gh.factory<_i447.TasksBloc>(() => _i447.TasksBloc(
          gh<_i517.GetTasks>(),
          gh<_i793.AddTask>(),
          gh<_i739.UpdateTask>(),
          gh<_i840.DeleteTask>(),
          gh<_i517.GetTasksStream>(),
        ));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i692.SignInWithGoogle>(),
          gh<_i59.FirebaseAuth>(instanceName: 'firebaseAuth'),
          gh<_i466.SignInWithEmailPassword>(),
          gh<_i1066.ResetPassword>(),
        ));
    return this;
  }
}

class _$RegisterModules extends _i759.RegisterModules {}
