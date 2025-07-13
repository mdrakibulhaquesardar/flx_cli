# 🚀 FLX CLI

**A powerful Flutter Clean Architecture CLI tool for generating scalable project structures with GetX/BLoC state management, Freezed models, and comprehensive boilerplate code.**

[![pub package](https://img.shields.io/pub/v/flx_cli.svg)](https://pub.dev/packages/flx_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Features

- 🏗️ **Clean Architecture**: Generate complete Clean Architecture structure
- 🎮 **State Management**: Support for GetX and BLoC patterns
- 🧊 **Freezed Integration**: Automatic Freezed model generation
- ⚖️ **Equatable Support**: Optional Equatable for value equality
- 🔧 **Highly Configurable**: Customize via `.flxrc.json` config file
- 📦 **Feature Generation**: Complete feature with all layers
- 🎯 **Individual Components**: Generate models, repositories, use cases separately
- 📱 **Screen Generation**: Create complete screens with state management
- 🌍 **Multi-language**: Documentation and examples in Bangla and English

## 🚀 Quick Start

## 📚 Documentation

- **Complete Documentation**: [FLX CLI Docs](https://flx-doc.netlify.app)
- **Clean Architecture Guide**: Learn Clean Architecture patterns
- **Best Practices**: Follow Flutter development best practices
- **Troubleshooting**: Common issues and solutions

### Installation

```bash
dart pub global activate flx_cli
```

### Basic Usage

```bash
# Initialize configuration
flx config init

# Generate a complete feature
flx gen feature auth

# Generate individual components
flx gen model User
flx gen screen profile
flx gen usecase GetUserData
```

## 📁 Generated Structure

```
lib/
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_data_source.dart
        │   ├── models/
        │   │   └── auth_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── auth_entity.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── usecases/
        │       └── auth_usecase.dart
        └── presentation/
            ├── bindings/
            │   └── auth_binding.dart
            ├── controllers/         # GetX
            │   └── auth_controller.dart
            ├── bloc/               # BLoC
            │   ├── auth_bloc.dart
            │   ├── auth_event.dart
            │   └── auth_state.dart
            └── pages/
                └── auth_page.dart
```

## ⚙️ Configuration

Create `.flxrc.json` in your project root:

```json
{
  "useFreezed": true,
  "useEquatable": false,
  "defaultStateManager": "getx",
  "author": "Your Name"
}
```

### State Management Options

- **GetX**: `"defaultStateManager": "getx"`
- **BLoC**: `"defaultStateManager": "bloc"`

## 📖 Commands

| Command | Description |
|---------|-------------|
| `flx config init` | Initialize configuration file |
| `flx config state-manager <type>` | Set state manager (getx/bloc) |
| `flx gen feature <name>` | Generate complete feature |
| `flx gen model <name>` | Generate data model |
| `flx gen screen <name>` | Generate screen with state management |
| `flx gen usecase <name>` | Generate use case |
| `flx gen repository <name>` | Generate repository |

## 🧊 Freezed Example

When `useFreezed: true`:

```dart
@freezed
class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String id,
    required String email,
    required String name,
  }) = _AuthModel;
  
  factory AuthModel.fromJson(Map<String, dynamic> json) => 
      _$AuthModelFromJson(json);
}
```

## 🎮 GetX Controller Example

```dart
class AuthController extends GetxController {
  final AuthUseCase _authUseCase;
  
  AuthController(this._authUseCase);
  
  final _isLoading = false.obs;
  final _authList = <AuthEntity>[].obs;
  
  bool get isLoading => _isLoading.value;
  List<AuthEntity> get authList => _authList;
  
  Future<void> loadAuth() async {
    try {
      _isLoading.value = true;
      final result = await _authUseCase();
      _authList.value = result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
}
```

## 🧱 BLoC Example

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase _authUseCase;
  
  AuthBloc(this._authUseCase) : super(AuthInitial()) {
    on<LoadAuth>(_onLoadAuth);
  }
  
  Future<void> _onLoadAuth(
    LoadAuth event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authUseCase();
      emit(AuthLoaded(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

## 📦 Required Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  # State Management (choose one)
  get: ^4.6.5                    # For GetX
  flutter_bloc: ^8.1.3          # For BLoC
  
  # Code Generation
  freezed_annotation: ^2.4.1    # If using Freezed
  equatable: ^2.0.5             # If using Equatable

dev_dependencies:
  # Build Tools
  freezed: ^2.4.7               # If using Freezed
  build_runner: ^2.4.7          # For code generation
  json_annotation: ^4.8.1       # For JSON serialization
```

## 🛠️ Build Runner Commands

For Freezed code generation:

```bash
# One-time build
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Support

- ⭐ Star this repository if it helped you!
- 🐛 [Report bugs](https://github.com/mdrakibulhaquesardar/flx-cli/issues)
- 💡 [Request features](https://github.com/mdrakibulhaquesardar/flx-cli/issues)
- 📧 [Contact us](mailto:rakibulhaques@gmail.com)

---

**Made with ❤️ for the Flutter community**
