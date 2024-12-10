Detailed Explanation

1. main.dart
Entry point of the application.
Wraps the app in ProviderScope for Riverpod.
Sets up routing and navigation.
2. core/
Contains shared resources and core utilities used throughout the app.
usecases/
Defines generic use cases or abstract logic that can be reused in multiple modules.
utils/
Includes helper functions, constants, and reusable classes.
3. features/
Each feature (e.g., auth) is a self-contained module with its own layers.
data/
Contains repositories, data sources, and implementations.
Example: auth_repo.dart (interface) and auth_repo_impl.dart (implementation).
domain/
Defines entities, use cases, and state models for the feature.
Keeps the business logic decoupled from the UI.
presentation/
The UI layer, including screens and widgets.
Example: auth_screen.dart (authentication screen) and login_form.dart (login widget).
providers/
Contains Riverpod providers and state management logic.
Example: auth_provider.dart (providers for repository and use cases) and auth_notifier.dart (state management with StateNotifier).
4. shared/
Resources that can be reused across multiple features.
widgets/
Contains common widgets like buttons, text fields, or custom loaders.
services/
Shared services like API clients or database handlers.
theme/
Centralized location for theming and styling.
