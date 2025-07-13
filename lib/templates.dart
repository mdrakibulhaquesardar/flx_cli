import 'dart:convert';
import 'dart:io';

class ConfigModel {
  final bool useFreezed;
  final bool useEquatable;
  final String defaultStateManager;
  final String author;
  
  ConfigModel({
    required this.useFreezed,
    required this.useEquatable,
    required this.defaultStateManager,
    required this.author,
  });
  
  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      useFreezed: json['useFreezed'] ?? true,
      useEquatable: json['useEquatable'] ?? false,
      defaultStateManager: json['defaultStateManager'] ?? 'getx',
      author: json['author'] ?? 'Developer',
    );
  }
  
  static Future<ConfigModel> load() async {
    final configFile = File('.flxrc.json');
    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ConfigModel.fromJson(json);
    }
    
    // Return default config if file doesn't exist
    return ConfigModel(
      useFreezed: true,
      useEquatable: false,
      defaultStateManager: 'getx',
      author: 'Developer',
    );
  }
}

class TemplateGenerator {
  final ConfigModel config;
  
  TemplateGenerator(this.config);
  
  String toCamelCase(String text) {
    if (text.isEmpty) return text;
    final words = text.split(RegExp(r'[_\-\s]+'));
    return words.first.toLowerCase() + 
           words.skip(1).map((word) => word.capitalize()).join();
  }
  
  String toPascalCase(String text) {
    if (text.isEmpty) return text;
    final words = text.split(RegExp(r'[_\-\s]+'));
    return words.map((word) => word.capitalize()).join();
  }
  
  String toSnakeCase(String text) {
    return text
        .replaceAll(RegExp(r'[A-Z]'), '_\$&')
        .replaceAll(RegExp(r'[-\s]+'), '_')
        .toLowerCase()
        .replaceAll(RegExp(r'^_'), '');
  }
  
  // Entity Template
  String generateEntity(String name) {
    final className = toPascalCase(name);
    
    if (config.useFreezed) {
      return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${toSnakeCase(name)}_entity.freezed.dart';

@freezed
class ${className}Entity with _\$${className}Entity {
  const factory ${className}Entity({
    required String id,
    // Add your entity properties here
  }) = _${className}Entity;
}
''';
    }
    
    if (config.useEquatable) {
      return '''
import 'package:equatable/equatable.dart';

class ${className}Entity extends Equatable {
  const ${className}Entity({
    required this.id,
    // Add your entity properties here
  });
  
  final String id;
  
  @override
  List<Object?> get props => [id];
}
''';
    }
    
    return '''
class ${className}Entity {
  const ${className}Entity({
    required this.id,
    // Add your entity properties here
  });
  
  final String id;
}
''';
  }
  
  // Model Template
  String generateModel(String name) {
    final className = toPascalCase(name);
    
    if (config.useFreezed) {
      return '''
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/${toSnakeCase(name)}_entity.dart';

part '${toSnakeCase(name)}_model.freezed.dart';
part '${toSnakeCase(name)}_model.g.dart';

@freezed
class ${className}Model with _\$${className}Model {
  const factory ${className}Model({
    required String id,
    // Add your model properties here
  }) = _${className}Model;
  
  factory ${className}Model.fromJson(Map<String, dynamic> json) => _\$${className}ModelFromJson(json);
}

extension ${className}ModelX on ${className}Model {
  ${className}Entity toEntity() {
    return ${className}Entity(
      id: id,
      // Map your properties here
    );
  }
}
''';
    }
    
    return '''
import 'dart:convert';
import '../../domain/entities/${toSnakeCase(name)}_entity.dart';

class ${className}Model extends ${className}Entity {
  const ${className}Model({
    required super.id,
    // Add your model properties here
  });
  
  factory ${className}Model.fromJson(Map<String, dynamic> json) {
    return ${className}Model(
      id: json['id'] ?? '',
      // Map your JSON properties here
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Map your properties here
    };
  }
  
  factory ${className}Model.fromRawJson(String str) => 
      ${className}Model.fromJson(json.decode(str));
  
  String toRawJson() => json.encode(toJson());
}
''';
  }
  
  // Repository Interface Template
  String generateRepositoryInterface(String name) {
    final className = toPascalCase(name);
    
    return '''
import '../entities/${toSnakeCase(name)}_entity.dart';

abstract class ${className}Repository {
  Future<List<${className}Entity>> getAll();
  Future<${className}Entity?> getById(String id);
  Future<${className}Entity> create(${className}Entity entity);
  Future<${className}Entity> update(${className}Entity entity);
  Future<void> delete(String id);
}
''';
  }
  
  // Repository Implementation Template
  String generateRepositoryImplementation(String name) {
    final className = toPascalCase(name);
    
    return '''
import '../../domain/entities/${toSnakeCase(name)}_entity.dart';
import '../../domain/repositories/${toSnakeCase(name)}_repository.dart';
import '../datasources/${toSnakeCase(name)}_remote_data_source.dart';
import '../models/${toSnakeCase(name)}_model.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  const ${className}RepositoryImpl(this._remoteDataSource);
  
  final ${className}RemoteDataSource _remoteDataSource;
  
  @override
  Future<List<${className}Entity>> getAll() async {
    final models = await _remoteDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<${className}Entity?> getById(String id) async {
    final model = await _remoteDataSource.getById(id);
    return model?.toEntity();
  }
  
  @override
  Future<${className}Entity> create(${className}Entity entity) async {
    final model = ${className}Model(
      id: entity.id,
      // Map your properties here
    );
    final createdModel = await _remoteDataSource.create(model);
    return createdModel.toEntity();
  }
  
  @override
  Future<${className}Entity> update(${className}Entity entity) async {
    final model = ${className}Model(
      id: entity.id,
      // Map your properties here
    );
    final updatedModel = await _remoteDataSource.update(model);
    return updatedModel.toEntity();
  }
  
  @override
  Future<void> delete(String id) async {
    await _remoteDataSource.delete(id);
  }
}
''';
  }
  
  // Data Source Template
  String generateDataSource(String name) {
    final className = toPascalCase(name);
    
    return '''
import '../models/${toSnakeCase(name)}_model.dart';

abstract class ${className}RemoteDataSource {
  Future<List<${className}Model>> getAll();
  Future<${className}Model?> getById(String id);
  Future<${className}Model> create(${className}Model model);
  Future<${className}Model> update(${className}Model model);
  Future<void> delete(String id);
}

class ${className}RemoteDataSourceImpl implements ${className}RemoteDataSource {
  const ${className}RemoteDataSourceImpl();
  
  @override
  Future<List<${className}Model>> getAll() async {
    // TODO: Implement API call
    throw UnimplementedError('getAll() not implemented');
  }
  
  @override
  Future<${className}Model?> getById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError('getById() not implemented');
  }
  
  @override
  Future<${className}Model> create(${className}Model model) async {
    // TODO: Implement API call
    throw UnimplementedError('create() not implemented');
  }
  
  @override
  Future<${className}Model> update(${className}Model model) async {
    // TODO: Implement API call
    throw UnimplementedError('update() not implemented');
  }
  
  @override
  Future<void> delete(String id) async {
    // TODO: Implement API call
    throw UnimplementedError('delete() not implemented');
  }
}
''';
  }
  
  // UseCase Template
  String generateUseCase(String name) {
    final className = toPascalCase(name);
    
    return '''
import '../entities/${toSnakeCase(name)}_entity.dart';
import '../repositories/${toSnakeCase(name)}_repository.dart';

class ${className}UseCase {
  const ${className}UseCase(this._repository);
  
  final ${className}Repository _repository;
  
  Future<List<${className}Entity>> call() async {
    return await _repository.getAll();
  }
}
''';
  }
  
  // Controller Template
  String generateController(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    if (config.defaultStateManager == 'bloc') {
      return generateBlocController(name);
    }
    
    return '''
import 'package:get/get.dart';
import '../../domain/entities/${toSnakeCase(name)}_entity.dart';
import '../../domain/usecases/${toSnakeCase(name)}_usecase.dart';

class ${className}Controller extends GetxController {
  ${className}Controller(this._${variableName}UseCase);
  
  final ${className}UseCase _${variableName}UseCase;
  
  final _isLoading = false.obs;
  final _${variableName}List = <${className}Entity>[].obs;
  
  bool get isLoading => _isLoading.value;
  List<${className}Entity> get ${variableName}List => _${variableName}List;
  
  @override
  void onInit() {
    super.onInit();
    load${className}s();
  }
  
  Future<void> load${className}s() async {
    try {
      _isLoading.value = true;
      final result = await _${variableName}UseCase();
      _${variableName}List.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ${variableName}s: \$e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refresh() async {
    await load${className}s();
  }
}
''';
  }
  
  // BLoC Controller Template
  String generateBlocController(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/${toSnakeCase(name)}_entity.dart';
import '../../domain/usecases/${toSnakeCase(name)}_usecase.dart';

part '${toSnakeCase(name)}_event.dart';
part '${toSnakeCase(name)}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc(this._${variableName}UseCase) : super(${className}Initial()) {
    on<Load${className}s>(_onLoad${className}s);
    on<Refresh${className}s>(_onRefresh${className}s);
  }
  
  final ${className}UseCase _${variableName}UseCase;
  
  Future<void> _onLoad${className}s(
    Load${className}s event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());
    try {
      final result = await _${variableName}UseCase();
      emit(${className}Loaded(result));
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }
  
  Future<void> _onRefresh${className}s(
    Refresh${className}s event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());
    try {
      final result = await _${variableName}UseCase();
      emit(${className}Loaded(result));
    } catch (e) {
      emit(${className}Error(e.toString()));
    }
  }
}
''';
  }
  
  // BLoC Event Template
  String generateBlocEvent(String name) {
    final className = toPascalCase(name);
    
    return '''
part of '${toSnakeCase(name)}_bloc.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();
  
  @override
  List<Object> get props => [];
}

class Load${className}s extends ${className}Event {
  const Load${className}s();
}

class Refresh${className}s extends ${className}Event {
  const Refresh${className}s();
}
''';
  }
  
  // BLoC State Template
  String generateBlocState(String name) {
    final className = toPascalCase(name);
    
    return '''
part of '${toSnakeCase(name)}_bloc.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();
  
  @override
  List<Object> get props => [];
}

class ${className}Initial extends ${className}State {
  const ${className}Initial();
}

class ${className}Loading extends ${className}State {
  const ${className}Loading();
}

class ${className}Loaded extends ${className}State {
  const ${className}Loaded(this.${toCamelCase(name)}List);
  
  final List<${className}Entity> ${toCamelCase(name)}List;
  
  @override
  List<Object> get props => [${toCamelCase(name)}List];
}

class ${className}Error extends ${className}State {
  const ${className}Error(this.message);
  
  final String message;
  
  @override
  List<Object> get props => [message];
}
''';
  }
  
  // Page Template
  String generatePage(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    if (config.defaultStateManager == 'bloc') {
      return generateBlocPage(name);
    }
    
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/${toSnakeCase(name)}_controller.dart';

class ${className}Page extends GetView<${className}Controller> {
  const ${className}Page({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${className}'),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            itemCount: controller.${variableName}List.length,
            itemBuilder: (context, index) {
              final item = controller.${variableName}List[index];
              return ListTile(
                title: Text(item.id),
                // Add more UI components here
              );
            },
          ),
        );
      }),
    );
  }
}
''';
  }
  
  // BLoC Page Template
  String generateBlocPage(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${toSnakeCase(name)}_bloc.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${className}'),
      ),
      body: BlocBuilder<${className}Bloc, ${className}State>(
        builder: (context, state) {
          if (state is ${className}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ${className}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: \${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<${className}Bloc>().add(const Refresh${className}s()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is ${className}Loaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<${className}Bloc>().add(const Refresh${className}s());
              },
              child: ListView.builder(
                itemCount: state.${variableName}List.length,
                itemBuilder: (context, index) {
                  final item = state.${variableName}List[index];
                  return ListTile(
                    title: Text(item.id),
                    // Add more UI components here
                  );
                },
              ),
            );
          }
          
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
''';
  }
  
  // Binding Template
  String generateBinding(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    if (config.defaultStateManager == 'bloc') {
      return generateBlocBinding(name);
    }
    
    return '''
import 'package:get/get.dart';
import '../../data/datasources/${toSnakeCase(name)}_remote_data_source.dart';
import '../../data/repositories/${toSnakeCase(name)}_repository_impl.dart';
import '../../domain/repositories/${toSnakeCase(name)}_repository.dart';
import '../../domain/usecases/${toSnakeCase(name)}_usecase.dart';
import '../controllers/${toSnakeCase(name)}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}RemoteDataSource>(
      () => ${className}RemoteDataSourceImpl(),
    );
    
    Get.lazyPut<${className}Repository>(
      () => ${className}RepositoryImpl(Get.find()),
    );
    
    Get.lazyPut<${className}UseCase>(
      () => ${className}UseCase(Get.find()),
    );
    
    Get.lazyPut<${className}Controller>(
      () => ${className}Controller(Get.find()),
    );
  }
}
''';
  }
  
  // BLoC Binding Template (Provider)
  String generateBlocBinding(String name) {
    final className = toPascalCase(name);
    final variableName = toCamelCase(name);
    
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/${toSnakeCase(name)}_remote_data_source.dart';
import '../../data/repositories/${toSnakeCase(name)}_repository_impl.dart';
import '../../domain/repositories/${toSnakeCase(name)}_repository.dart';
import '../../domain/usecases/${toSnakeCase(name)}_usecase.dart';
import '../bloc/${toSnakeCase(name)}_bloc.dart';

class ${className}Provider {
  static void init() {
    final getIt = GetIt.instance;
    
    // Data Sources
    getIt.registerLazySingleton<${className}RemoteDataSource>(
      () => ${className}RemoteDataSourceImpl(),
    );
    
    // Repositories
    getIt.registerLazySingleton<${className}Repository>(
      () => ${className}RepositoryImpl(getIt()),
    );
    
    // Use Cases
    getIt.registerLazySingleton<${className}UseCase>(
      () => ${className}UseCase(getIt()),
    );
    
    // BLoC
    getIt.registerFactory<${className}Bloc>(
      () => ${className}Bloc(getIt()),
    );
  }
  
  static BlocProvider<${className}Bloc> provide({
    required Widget child,
  }) {
    return BlocProvider<${className}Bloc>(
      create: (context) => GetIt.instance<${className}Bloc>()..add(const Load${className}s()),
      child: child,
    );
  }
}
''';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
} 