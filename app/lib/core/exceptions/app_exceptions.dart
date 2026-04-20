class AppException implements Exception {
  final String message;
  final String? prefix;
  final String? code;

  AppException(this.message, {this.prefix, this.code});

  @override
  String toString() {
    return '${prefix != null ? '$prefix: ' : ''}$message';
  }
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Please check your internet connection'])
      : super(prefix: 'Network Error', code: 'network_error');
}

class AuthException extends AppException {
  AuthException([super.message = 'Authentication failed. Please try again.'])
      : super(prefix: 'Auth Error', code: 'auth_error');
}

class DatabaseException extends AppException {
  DatabaseException([super.message = 'Failed to perform database operation.'])
      : super(prefix: 'Database Error', code: 'db_error');
}

class LocalException extends AppException {
  LocalException(super.message)
      : super(prefix: 'App Error', code: 'local_error');
}
