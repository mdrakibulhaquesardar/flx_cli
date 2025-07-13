import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'templates.dart';
import 'file_generator.dart';

class FlxCli {
  static const String version = '1.0.0';
  
  Future<void> run(List<String> arguments) async {
    // Handle special case for config --state command
    if (arguments.length >= 3 && arguments[0] == 'config' && arguments[1] == '--state') {
      await _setStateManager(arguments[2]);
      return;
    }
    
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show this help message')
      ..addFlag('version', abbr: 'v', help: 'Show version information');
    
    try {
      final results = parser.parse(arguments);
      
      if (results['help']) {
        _showHelp();
        return;
      }
      
      if (results['version']) {
        _showVersion();
        return;
      }
      
      if (results.rest.isEmpty) {
        _showHelp();
        return;
      }
      
      final command = results.rest.first;
      final args = results.rest.skip(1).toList();
      
      switch (command) {
        case 'gen':
          await _handleGenCommand(args);
          break;
        case 'config':
          await _handleConfigCommand(args);
          break;
        default:
          print('Unknown command: $command');
          _showHelp();
      }
    } catch (e) {
      print('Error: $e');
      _showHelp();
    }
  }
  
  void _showHelp() {
    print('''
FLX CLI - Flutter Clean Architecture Generator

Usage: flx <command> [arguments]

Available commands:
  gen feature <name>     Generate a full Clean Architecture feature structure
  gen screen <name>      Generate a new screen (page + controller + binding)
  gen model <name>       Generate a model class
  gen usecase <name>     Generate a domain usecase class
  gen repository <name>  Generate repository classes (abstract + implementation)
  config init           Initialize a .flxrc.json config file
  config --state <manager>  Set state manager (getx or bloc)

Global options:
  -h, --help            Show this help message
  -v, --version         Show version information

Examples:
  flx gen feature auth
  flx gen screen login
  flx gen model user
  flx config init
  flx config --state bloc
  flx config --state getx
''');
  }
  
  void _showVersion() {
    print('FLX CLI version $version');
  }
  
  Future<void> _handleGenCommand(List<String> args) async {
    if (args.isEmpty) {
      print('Error: gen command requires a subcommand');
      _showGenHelp();
      return;
    }
    
    final subCommand = args.first;
    final name = args.length > 1 ? args[1] : null;
    
    if (name == null || name.isEmpty) {
      print('Error: $subCommand requires a name');
      return;
    }
    
    switch (subCommand) {
      case 'feature':
        await _generateFeature(name);
        break;
      case 'screen':
        await _generateScreen(name);
        break;
      case 'model':
        await _generateModel(name);
        break;
      case 'usecase':
        await _generateUsecase(name);
        break;
      case 'repository':
        await _generateRepository(name);
        break;
      default:
        print('Unknown gen subcommand: $subCommand');
        _showGenHelp();
    }
  }
  
  void _showGenHelp() {
    print('''
Available gen subcommands:
  feature <name>     Generate a full Clean Architecture feature structure
  screen <name>      Generate a new screen (page + controller + binding)
  model <name>       Generate a model class
  usecase <name>     Generate a domain usecase class
  repository <name>  Generate repository classes (abstract + implementation)
''');
  }
  
  Future<void> _handleConfigCommand(List<String> args) async {
    if (args.isEmpty) {
      print('Error: config command requires a subcommand or flag');
      print('Available: config init, config --state <manager>');
      return;
    }
    
    // Check for --state flag
    if (args.contains('--state')) {
      final stateIndex = args.indexOf('--state');
      if (stateIndex + 1 < args.length) {
        final stateManager = args[stateIndex + 1];
        await _setStateManager(stateManager);
        return;
      } else {
        print('❌ Error: --state requires a value (getx or bloc)');
        return;
      }
    }
    
    final subCommand = args.first;
    
    switch (subCommand) {
      case 'init':
        await _initConfig();
        break;
      default:
        print('Unknown config subcommand: $subCommand');
        print('Available: config init, config --state <manager>');
    }
  }
  
  Future<void> _generateFeature(String name) async {
    print('Generating feature: $name');
    try {
      final config = await ConfigModel.load();
      final templateGenerator = TemplateGenerator(config);
      final fileGenerator = FileGenerator(templateGenerator);
      
      await fileGenerator.generateFeature(name);
    } catch (e) {
      print('❌ Error generating feature: $e');
    }
  }
  
  Future<void> _generateScreen(String name) async {
    print('Generating screen: $name');
    try {
      final config = await ConfigModel.load();
      final templateGenerator = TemplateGenerator(config);
      final fileGenerator = FileGenerator(templateGenerator);
      
      await fileGenerator.generateScreen(name);
    } catch (e) {
      print('❌ Error generating screen: $e');
    }
  }
  
  Future<void> _generateModel(String name) async {
    print('Generating model: $name');
    try {
      final config = await ConfigModel.load();
      final templateGenerator = TemplateGenerator(config);
      final fileGenerator = FileGenerator(templateGenerator);
      
      await fileGenerator.generateModel(name);
    } catch (e) {
      print('❌ Error generating model: $e');
    }
  }
  
  Future<void> _generateUsecase(String name) async {
    print('Generating usecase: $name');
    try {
      final config = await ConfigModel.load();
      final templateGenerator = TemplateGenerator(config);
      final fileGenerator = FileGenerator(templateGenerator);
      
      await fileGenerator.generateUseCase(name);
    } catch (e) {
      print('❌ Error generating usecase: $e');
    }
  }
  
  Future<void> _generateRepository(String name) async {
    print('Generating repository: $name');
    try {
      final config = await ConfigModel.load();
      final templateGenerator = TemplateGenerator(config);
      final fileGenerator = FileGenerator(templateGenerator);
      
      await fileGenerator.generateRepository(name);
    } catch (e) {
      print('❌ Error generating repository: $e');
    }
  }
  
  Future<void> _initConfig() async {
    print('Initializing .flxrc.json config file...');
    
    final configFile = File('.flxrc.json');
    
    if (await configFile.exists()) {
      print('Config file already exists at .flxrc.json');
      stdout.write('Do you want to overwrite it? (y/n): ');
      final response = stdin.readLineSync()?.toLowerCase();
      if (response != 'y' && response != 'yes') {
        print('Config initialization cancelled.');
        return;
      }
    }
    
    const defaultConfig = '''{
  "useFreezed": true,
  "useEquatable": false,
  "defaultStateManager": "getx",
  "author": "Developer"
}''';
    
    try {
      await configFile.writeAsString(defaultConfig);
      print('✅ Successfully created .flxrc.json config file');
      print('You can now edit this file to customize your preferences.');
    } catch (e) {
      print('❌ Error creating config file: $e');
    }
  }
  
  Future<void> _setStateManager(String stateManager) async {
    final validStateManagers = ['getx', 'bloc'];
    
    if (!validStateManagers.contains(stateManager.toLowerCase())) {
      print('❌ Invalid state manager. Use "getx" or "bloc".');
      return;
    }
    
    final configFile = File('.flxrc.json');
    
    try {
      Map<String, dynamic> config = {
        "useFreezed": true,
        "useEquatable": false,
        "defaultStateManager": "getx",
        "author": "Developer"
      };
      
      // Load existing config if it exists
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        config = json.decode(content) as Map<String, dynamic>;
      }
      
      // Update state manager
      config['defaultStateManager'] = stateManager.toLowerCase();
      
      // Save updated config
      final encoder = JsonEncoder.withIndent('  ');
      final formattedConfig = encoder.convert(config);
      await configFile.writeAsString(formattedConfig);
      
      print('✅ State manager set to: $stateManager');
      
    } catch (e) {
      print('❌ Error updating config: $e');
    }
  }
}
