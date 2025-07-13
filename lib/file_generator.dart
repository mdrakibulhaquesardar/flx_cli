import 'dart:io';
import 'package:path/path.dart' as path;
import 'templates.dart';

/// A utility class for generating Flutter project files and directory structures
/// following Clean Architecture principles.
/// 
/// The [FileGenerator] class handles the creation of files, directories, and
/// complete feature structures with proper naming conventions and templates.
/// 
/// Example usage:
/// ```dart
/// final templateGen = TemplateGenerator();
/// final fileGen = FileGenerator(templateGen);
/// await fileGen.generateFeature('user_profile');
/// ```
class FileGenerator {
  /// The template generator instance used for creating file contents.
  final TemplateGenerator templateGenerator;
  
  /// Creates a new [FileGenerator] with the specified [templateGenerator].
  /// 
  /// The [templateGenerator] is used to generate the actual content of files
  /// based on the configured state management pattern and other settings.
  FileGenerator(this.templateGenerator);
  
  /// Ensures that the specified directory path exists, creating it if necessary.
  /// 
  /// [dirPath] - The directory path to create.
  /// 
  /// This method creates the directory recursively, meaning it will create
  /// all necessary parent directories if they don't exist.
  Future<void> ensureDirectoryExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  
  /// Writes content to a file at the specified path.
  /// 
  /// [filePath] - The path where the file should be created.
  /// [content] - The content to write to the file.
  /// 
  /// This method ensures the parent directory exists before writing the file.
  /// If the file already exists, it will be overwritten.
  Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await ensureDirectoryExists(path.dirname(filePath));
    await file.writeAsString(content);
  }
  
  /// Generates a complete Clean Architecture feature structure.
  /// 
  /// [name] - The name of the feature to generate (e.g., 'user_profile', 'authentication').
  /// 
  /// This method creates a complete feature following Clean Architecture principles:
  /// - Data layer: datasources, models, repositories
  /// - Domain layer: entities, repositories (abstracts), usecases  
  /// - Presentation layer: pages, controllers/blocs, bindings
  /// 
  /// The generated structure adapts to the configured state management pattern
  /// (GetX or BLoC) and includes appropriate dependencies and imports.
  /// 
  /// Example:
  /// ```dart
  /// await fileGenerator.generateFeature('user_profile');
  /// // Creates: lib/features/user_profile/...
  /// ```
  Future<void> generateFeature(String name) async {
    final snakeName = templateGenerator.toSnakeCase(name);
    final isBloc = templateGenerator.config.defaultStateManager == 'bloc';
    
    // Create directory structure based on state manager
    final dirs = [
      'lib/features/$snakeName/data/datasources',
      'lib/features/$snakeName/data/models',
      'lib/features/$snakeName/data/repositories',
      'lib/features/$snakeName/domain/entities',
      'lib/features/$snakeName/domain/repositories',
      'lib/features/$snakeName/domain/usecases',
      'lib/features/$snakeName/presentation/pages',
      'lib/features/$snakeName/presentation/bindings',
    ];
    
    // Add state manager specific directories
    if (isBloc) {
      dirs.add('lib/features/$snakeName/presentation/bloc');
    } else {
      dirs.add('lib/features/$snakeName/presentation/controllers');
    }
    
    for (final dir in dirs) {
      await ensureDirectoryExists(dir);
    }
    
    // Generate common files
    final files = <String, String>{
      'lib/features/$snakeName/domain/entities/${snakeName}_entity.dart': 
          templateGenerator.generateEntity(name),
      'lib/features/$snakeName/data/models/${snakeName}_model.dart': 
          templateGenerator.generateModel(name),
      'lib/features/$snakeName/domain/repositories/${snakeName}_repository.dart': 
          templateGenerator.generateRepositoryInterface(name),
      'lib/features/$snakeName/data/repositories/${snakeName}_repository_impl.dart': 
          templateGenerator.generateRepositoryImplementation(name),
      'lib/features/$snakeName/data/datasources/${snakeName}_remote_data_source.dart': 
          templateGenerator.generateDataSource(name),
      'lib/features/$snakeName/domain/usecases/${snakeName}_usecase.dart': 
          templateGenerator.generateUseCase(name),
      'lib/features/$snakeName/presentation/pages/${snakeName}_page.dart': 
          templateGenerator.generatePage(name),
      'lib/features/$snakeName/presentation/bindings/${snakeName}_binding.dart': 
          templateGenerator.generateBinding(name),
    };
    
    // Add state manager specific files
    if (isBloc) {
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_bloc.dart'] = 
          templateGenerator.generateController(name);
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_event.dart'] = 
          templateGenerator.generateBlocEvent(name);
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_state.dart'] = 
          templateGenerator.generateBlocState(name);
    } else {
      files['lib/features/$snakeName/presentation/controllers/${snakeName}_controller.dart'] = 
          templateGenerator.generateController(name);
    }
    
    for (final entry in files.entries) {
      await writeFile(entry.key, entry.value);
    }
    
    print('✅ Generated feature "$name" with files:');
    for (final filePath in files.keys) {
      print('  - $filePath');
    }
  }
  
  /// Generates a standalone screen with controller and binding.
  /// 
  /// [name] - The name of the screen to generate (e.g., 'login', 'dashboard').
  /// 
  /// Creates a minimal screen structure suitable for simple pages that don't
  /// require the full Clean Architecture setup. Includes:
  /// - Page widget with proper routing
  /// - Controller/BLoC for state management  
  /// - Binding for dependency injection
  /// 
  /// The generated files adapt to the configured state management pattern.
  /// 
  /// Example:
  /// ```dart
  /// await fileGenerator.generateScreen('login');
  /// // Creates: lib/features/login/presentation/...
  /// ```
  Future<void> generateScreen(String name) async {
    final snakeName = templateGenerator.toSnakeCase(name);
    final isBloc = templateGenerator.config.defaultStateManager == 'bloc';
    
    // Create directory structure based on state manager
    final dirs = [
      'lib/features/$snakeName/presentation/pages',
      'lib/features/$snakeName/presentation/bindings',
    ];
    
    // Add state manager specific directories
    if (isBloc) {
      dirs.add('lib/features/$snakeName/presentation/bloc');
    } else {
      dirs.add('lib/features/$snakeName/presentation/controllers');
    }
    
    for (final dir in dirs) {
      await ensureDirectoryExists(dir);
    }
    
    // Generate common files
    final files = <String, String>{
      'lib/features/$snakeName/presentation/pages/${snakeName}_page.dart': 
          _generateSimplePage(name),
      'lib/features/$snakeName/presentation/bindings/${snakeName}_binding.dart': 
          _generateSimpleBinding(name),
    };
    
    // Add state manager specific files
    if (isBloc) {
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_bloc.dart'] = 
          _generateSimpleBlocController(name);
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_event.dart'] = 
          _generateSimpleBlocEvent(name);
      files['lib/features/$snakeName/presentation/bloc/${snakeName}_state.dart'] = 
          _generateSimpleBlocState(name);
    } else {
      files['lib/features/$snakeName/presentation/controllers/${snakeName}_controller.dart'] = 
          _generateSimpleController(name);
    }
    
    for (final entry in files.entries) {
      await writeFile(entry.key, entry.value);
    }
    
    print('✅ Generated screen "$name" with files:');
    for (final filePath in files.keys) {
      print('  - $filePath');
    }
  }
  
  /// Generates a standalone model class with optional Freezed/Equatable support.
  /// 
  /// [name] - The name of the model to generate (e.g., 'user', 'product').
  /// 
  /// Creates a data model class in `lib/shared/models/` with:
  /// - Proper naming conventions (snake_case files, PascalCase classes)
  /// - Freezed integration (if enabled in config)
  /// - Equatable support (if enabled in config)  
  /// - JSON serialization support
  /// - Appropriate imports and annotations
  /// 
  /// Example:
  /// ```dart
  /// await fileGenerator.generateModel('user');
  /// // Creates: lib/shared/models/user_model.dart
  /// ```
  Future<void> generateModel(String name) async {
    final snakeName = templateGenerator.toSnakeCase(name);
    
    // For standalone model generation, we'll put it in a shared models folder
    await ensureDirectoryExists('lib/shared/models');
    
    final content = templateGenerator.generateModel(name);
    final filePath = 'lib/shared/models/${snakeName}_model.dart';
    
    await writeFile(filePath, content);
    
    print('✅ Generated model "$name":');
    print('  - $filePath');
    print('💡 Note: Model generated in shared folder. For feature-specific models, use "flx gen feature <name>"');
  }
  
  /// Generates a standalone use case class following Clean Architecture principles.
  /// 
  /// [name] - The name of the use case to generate (e.g., 'get_user', 'authenticate').
  /// 
  /// Creates a domain use case class in `lib/shared/usecases/` with:
  /// - Proper use case structure with call() method
  /// - Type-safe parameters and return types
  /// - Error handling patterns
  /// - Repository dependency injection
  /// - Clean Architecture compliance
  /// 
  /// Example:
  /// ```dart
  /// await fileGenerator.generateUseCase('get_user');
  /// // Creates: lib/shared/usecases/get_user_usecase.dart
  /// ```
  Future<void> generateUseCase(String name) async {
    final snakeName = templateGenerator.toSnakeCase(name);
    
    // For standalone usecase generation, we'll put it in a shared usecases folder
    await ensureDirectoryExists('lib/shared/usecases');
    
    final content = templateGenerator.generateUseCase(name);
    final filePath = 'lib/shared/usecases/${snakeName}_usecase.dart';
    
    await writeFile(filePath, content);
    
    print('✅ Generated usecase "$name":');
    print('  - $filePath');
    print('💡 Note: UseCase generated in shared folder. For feature-specific usecases, use "flx gen feature <name>"');
  }
  
  /// Generates repository interface and implementation following Clean Architecture.
  /// 
  /// [name] - The name of the repository to generate (e.g., 'user', 'auth').
  /// 
  /// Creates both abstract repository interface and concrete implementation:
  /// - Abstract repository in `lib/shared/repositories/` (domain layer)
  /// - Concrete implementation in `lib/shared/repositories/implementations/` (data layer)
  /// - Proper dependency inversion with interface segregation
  /// - Error handling and type safety
  /// - Remote data source integration patterns
  /// 
  /// Example:
  /// ```dart
  /// await fileGenerator.generateRepository('user');
  /// // Creates: 
  /// //   lib/shared/repositories/user_repository.dart
  /// //   lib/shared/repositories/implementations/user_repository_impl.dart
  /// ```
  Future<void> generateRepository(String name) async {
    final snakeName = templateGenerator.toSnakeCase(name);
    
    // For standalone repository generation, we'll put it in shared folders
    await ensureDirectoryExists('lib/shared/repositories');
    await ensureDirectoryExists('lib/shared/repositories/implementations');
    
    final files = {
      'lib/shared/repositories/${snakeName}_repository.dart': 
          templateGenerator.generateRepositoryInterface(name),
      'lib/shared/repositories/implementations/${snakeName}_repository_impl.dart': 
          templateGenerator.generateRepositoryImplementation(name),
    };
    
    for (final entry in files.entries) {
      await writeFile(entry.key, entry.value);
    }
    
    print('✅ Generated repository "$name" with files:');
    for (final filePath in files.keys) {
      print('  - $filePath');
    }
    print('💡 Note: Repository generated in shared folder. For feature-specific repositories, use "flx gen feature <name>"');
  }
  
  String _generateSimpleController(String name) {
    final className = templateGenerator.toPascalCase(name);
    
    return '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final _isLoading = false.obs;
  
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize your controller here
  }
  
  @override
  void onReady() {
    super.onReady();
    // Called after the widget is rendered on screen
  }
  
  @override
  void onClose() {
    super.onClose();
    // Dispose of any resources
  }
}
''';
  }
  
  String _generateSimplePage(String name) {
    final className = templateGenerator.toPascalCase(name);
    final snakeName = templateGenerator.toSnakeCase(name);
    final isBloc = templateGenerator.config.defaultStateManager == 'bloc';
    
    if (isBloc) {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeName}_bloc.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className'),
      ),
      body: BlocBuilder<${className}Bloc, ${className}State>(
        builder: (context, state) {
          return const Center(
            child: Text(
              '$className Page',
              style: TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }
}
''';
    }
    
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/${snakeName}_controller.dart';

class ${className}Page extends GetView<${className}Controller> {
  const ${className}Page({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className'),
      ),
      body: const Center(
        child: Text(
          '$className Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
''';
  }
  
  String _generateSimpleBinding(String name) {
    final className = templateGenerator.toPascalCase(name);
    final snakeName = templateGenerator.toSnakeCase(name);
    final isBloc = templateGenerator.config.defaultStateManager == 'bloc';
    
    if (isBloc) {
      return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/${snakeName}_bloc.dart';

class ${className}Provider {
  static void init() {
    final getIt = GetIt.instance;
    
    // Register BLoC
    getIt.registerFactory<${className}Bloc>(
      () => ${className}Bloc(),
    );
  }
  
  static BlocProvider<${className}Bloc> provide({
    required Widget child,
  }) {
    return BlocProvider<${className}Bloc>(
      create: (context) => GetIt.instance<${className}Bloc>(),
      child: child,
    );
  }
}
''';
    }
    
    return '''
import 'package:get/get.dart';
import '../controllers/${snakeName}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}Controller>(
      () => ${className}Controller(),
    );
  }
}
''';
  }
  
  String _generateSimpleBlocController(String name) {
    final className = templateGenerator.toPascalCase(name);
    
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${templateGenerator.toSnakeCase(name)}_event.dart';
part '${templateGenerator.toSnakeCase(name)}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc() : super(${className}Initial()) {
    on<${className}Started>(_onStarted);
  }
  
  void _onStarted(${className}Started event, Emitter<${className}State> emit) {
    emit(${className}Loaded());
  }
}
''';
  }
  
  String _generateSimpleBlocEvent(String name) {
    final className = templateGenerator.toPascalCase(name);
    
    return '''
part of '${templateGenerator.toSnakeCase(name)}_bloc.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();
  
  @override
  List<Object> get props => [];
}

class ${className}Started extends ${className}Event {
  const ${className}Started();
}
''';
  }
  
  String _generateSimpleBlocState(String name) {
    final className = templateGenerator.toPascalCase(name);
    
    return '''
part of '${templateGenerator.toSnakeCase(name)}_bloc.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();
  
  @override
  List<Object> get props => [];
}

class ${className}Initial extends ${className}State {
  const ${className}Initial();
}

class ${className}Loaded extends ${className}State {
  const ${className}Loaded();
}
''';
  }
} 