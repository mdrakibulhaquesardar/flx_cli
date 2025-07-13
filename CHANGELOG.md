# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### 🎉 Initial Release

#### ✨ Features

- **Clean Architecture Generator**: Complete Clean Architecture structure with data, domain, and presentation layers
- **State Management Support**: 
  - GetX controllers with reactive state management
  - BLoC pattern with events, states, and business logic
- **Code Generation Integration**:
  - Freezed models for immutable data classes
  - Equatable support for value equality
  - JSON serialization with json_annotation
- **Feature Generation**: Full feature generation with all architectural layers
- **Individual Component Generation**:
  - Models with Freezed/Equatable options
  - Repositories with implementation
  - Use cases for business logic
  - Screens with state management
- **Configuration System**: 
  - `.flxrc.json` configuration file
  - Customizable state manager selection
  - Toggleable Freezed/Equatable usage
  - Author name configuration

#### 🛠️ Commands

- `flx config init` - Initialize configuration file
- `flx config state-manager <type>` - Set default state manager (getx/bloc)
- `flx gen feature <name>` - Generate complete feature with all layers
- `flx gen model <name>` - Generate data model
- `flx gen screen <name>` - Generate screen with state management
- `flx gen usecase <name>` - Generate use case
- `flx gen repository <name>` - Generate repository

#### 🏗️ Architecture

- **Data Layer**: Remote data sources, models, repository implementations
- **Domain Layer**: Entities, repository contracts, use cases
- **Presentation Layer**: Controllers/BLoC, bindings, pages

#### 📦 Dependencies

- `args: ^2.4.2` - Command line argument parsing
- `path: ^1.9.0` - File system path manipulation

#### 🧪 Testing

- Comprehensive unit tests for CLI functionality
- Template generation testing
- Configuration management testing

#### 📚 Documentation

- Complete getting started guide
- Clean Architecture principles
- State management comparisons
- Configuration options
- Best practices and naming conventions

### 🎯 Supported Patterns

- **GetX**: Reactive state management with dependency injection
- **BLoC**: Business Logic Component pattern with events and states
- **Freezed**: Immutable data classes with copy semantics
- **Equatable**: Value equality for entities and models

### 🔧 Configuration Options

```json
{
  "useFreezed": true,
  "useEquatable": false,
  "defaultStateManager": "getx",
  "author": "Developer"
}
```

### 📁 Generated Structure Example

```
lib/features/auth/
├── data/
│   ├── datasources/auth_remote_data_source.dart
│   ├── models/auth_model.dart
│   └── repositories/auth_repository_impl.dart
├── domain/
│   ├── entities/auth_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/auth_usecase.dart
└── presentation/
    ├── bindings/auth_binding.dart
    ├── controllers/auth_controller.dart (GetX)
    ├── bloc/ (BLoC)
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── pages/auth_page.dart
```
