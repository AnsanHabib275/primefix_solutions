class ErrorHandler {
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    // Log error
    Logger.error('Error occurred', error: error, stackTrace: stackTrace);

    // Send to crash reporting service
    FirebaseCrashlytics.instance.recordError(error, stackTrace);

    // Show user-friendly message
    String userMessage = _getUserFriendlyMessage(error);
    Get.snackbar('Error', userMessage, backgroundColor: Colors.red);
  }

  static String _getUserFriendlyMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return 'Please log in again';
        case 403:
          return 'You don\'t have permission to perform this action';
        case 404:
          return 'The requested resource was not found';
        case 500:
          return 'Server error. Please try again later';
        default:
          return error.message ?? 'Something went wrong';
      }
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

// Global error boundary
class AppErrorBoundary extends StatelessWidget {
  final Widget child;

  const AppErrorBoundary({required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      ErrorHandler.handleError(details.exception, details.stack);

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Something went wrong', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Phoenix.rebirth(context),
                child: Text('Restart App'),
              ),
            ],
          ),
        ),
      );
    };

    return child;
  }
}
