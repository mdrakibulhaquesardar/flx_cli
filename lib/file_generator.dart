import 'dart:io';
import 'package:path/path.dart' as path;
import 'templates.dart';

class FileGenerator {
  final TemplateGenerator templateGenerator;
  
  FileGenerator(this.templateGenerator);
  
  Future<void> ensureDirectoryExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  
  Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await ensureDirectoryExists(path.dirname(filePath));
    await file.writeAsString(content);
  }
  
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