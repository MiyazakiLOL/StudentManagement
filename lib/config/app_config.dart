class AppConfig {
  const AppConfig._();

  /// Base URL of the backend API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Public API (acts as a demo datasource for "students")
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  /// Path to fetch students list.
  static const String studentsPath = String.fromEnvironment(
    'STUDENTS_PATH',
    // JSONPlaceholder exposes user list at /users
    defaultValue: '/users',
  );
}
