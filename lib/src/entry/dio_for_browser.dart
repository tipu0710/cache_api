import '../options.dart';
import '../sdio.dart';
import '../adapters/browser_adapter.dart';

SDio createDio([BaseOptions options]) => DioForBrowser(options);

class DioForBrowser with DioMixin implements SDio {
  /// Create Dio instance with default [Options].
  /// It's mostly just one Dio instance in your application.
  DioForBrowser([BaseOptions options]) {
    this.options = options ?? BaseOptions();
    httpClientAdapter = BrowserHttpClientAdapter();
  }
}
