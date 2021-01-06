import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'adapter.dart';
import 'form_data.dart';
import 'options.dart';
import 'interceptor.dart';
import 'headers.dart';
import 'cancel_token.dart';
import 'transformer.dart';
import 'response.dart';
import 'cache_api_error.dart';
import 'entry_stub.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) 'entry/cache_api_for_native.dart';

/// A powerful Http client for Dart, which supports Interceptors,
/// Global configuration, FormData, File downloading etc. and CacheApi is
/// very easy to use.
///
/// You can create a cacheApi instance and config it by two ways:
/// 1. create first , then config it
///
///   ```dart
///    var cacheApi = CacheApi();
///    cacheApi.options.baseUrl = "http://www.dtworkroom.com/doris/1/2.0.0/";
///    cacheApi.options.connectTimeout = 5000; //5s
///    cacheApi.options.receiveTimeout = 5000;
///    cacheApi.options.headers = {HttpHeaders.userAgentHeader: 'cacheApi', 'common-header': 'xx'};
///   ```
/// 2. create and config it:
///
/// ```dart
///   var cacheApi = CacheApi(BaseOptions(
///    baseUrl: "http://www.dtworkroom.com/doris/1/2.0.0/",
///    connectTimeout: 5000,
///    receiveTimeout: 5000,
///    headers: {HttpHeaders.userAgentHeader: 'cacheApi', 'common-header': 'xx'},
///   ));
///  ```

abstract class CacheApi {
  factory CacheApi([BaseOptions options]) => createCacheApi(options);

  /// Default Request config. More see [BaseOptions] .
  BaseOptions options;

  Interceptors get interceptors;

  HttpClientAdapter httpClientAdapter;

  /// [transformer] allows changes to the request/response data before it is sent/received to/from the server
  /// This is only applicable for request methods 'PUT', 'POST', and 'PATCH'.
  Transformer transformer;

  /// Shuts down the cacheApi client.
  ///
  /// If [force] is `false` (the default) the [CacheApi] will be kept alive
  /// until all active connections are done. If [force] is `true` any active
  /// connections will be closed to immediately release all resources. These
  /// closed connections will receive an error event to indicate that the client
  /// was shut down. In both cases trying to establish a new connection after
  /// calling [close] will throw an exception.
  void close({bool force = false});

  Box box;

  Future<void> init();

  /// Handy method to make http GET request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    bool storeData,
    Duration duration,
  });

  /// Handy method to make http GET request, which is a alias of [BaseCacheApi.request].
  Future<ApiResponse<T>> getUri<T>(
    Uri uri, {
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http POST request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http POST request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> postUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http PUT request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http PUT request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> putUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http HEAD request, which is a alias of [BaseCacheApi.request].
  Future<ApiResponse<T>> head<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
  });

  /// Handy method to make http HEAD request, which is a alias of [BaseCacheApi.request].
  Future<ApiResponse<T>> headUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
  });

  /// Handy method to make http DELETE request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
  });

  /// Handy method to make http DELETE request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> deleteUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
  });

  /// Handy method to make http PATCH request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Handy method to make http PATCH request, which is a alias of  [BaseCacheApi.request].
  Future<ApiResponse<T>> patchUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  });

  /// Assure the final future state is succeed!
  Future<ApiResponse<T>> resolve<T>(response);

  /// Assure the final future state is failed!
  Future<ApiResponse<T>> reject<T>(err);

  /// Lock the current CacheApi instance.
  ///
  /// CacheApi will enqueue the incoming request tasks instead
  /// send them directly when [interceptor.request] is locked.

  void lock();

  /// Unlock the current CacheApi instance.
  ///
  /// CacheApi instance dequeue the request task。
  void unlock();

  ///Clear the current CacheApi instance waiting queue.

  void clear();

  ///  Download the file and save it in local. The default http method is "GET",
  ///  you can custom it by [Options.method].
  ///
  ///  [urlPath]: The file url.
  ///
  ///  [savePath]: The path to save the downloading file later. it can be a String or
  ///  a callback:
  ///  1. A path with String type, eg "xs.jpg"
  ///  2. A callback `String Function(HttpHeaders responseHeaders)`; for example:
  ///  ```dart
  ///   await cacheApi.download(url,(HttpHeaders responseHeaders){
  ///      ...
  ///      return "...";
  ///    });
  ///  ```
  ///
  ///  [onReceiveProgress]: The callback to listen downloading progress.
  ///  please refer to [ProgressCallback].
  ///
  /// [deleteOnError] Whether delete the file when error occurs. The default value is [true].
  ///
  ///  [lengthHeader] : The real size of original file (not compressed).
  ///  When file is compressed:
  ///  1. If this value is 'content-length', the `total` argument of `onProgress` will be -1
  ///  2. If this value is not 'content-length', maybe a custom header indicates the original
  ///  file size , the `total` argument of `onProgress` will be this header value.
  ///
  ///  you can also disable the compression by specifying the 'accept-encoding' header value as '*'
  ///  to assure the value of `total` argument of `onProgress` is not -1. for example:
  ///
  ///     await cacheApi.download(url, "./example/flutter.svg",
  ///     options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),  // disable gzip
  ///     onProgress: (received, total) {
  ///       if (total != -1) {
  ///        print((received / total * 100).toStringAsFixed(0) + "%");
  ///       }
  ///     });

  Future<ApiResponse> download(
    String urlPath,
    savePath, {
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options options,
  });

  ///  Download the file and save it in local. The default http method is "GET",
  ///  you can custom it by [Options.method].
  ///
  ///  [uri]: The file url.
  ///
  ///  [savePath]: The path to save the downloading file later. it can be a String or
  ///  a callback:
  ///  1. A path with String type, eg "xs.jpg"
  ///  2. A callback `String Function(HttpHeaders responseHeaders)`; for example:
  ///  ```dart
  ///   await cacheApi.downloadUri(uri,(HttpHeaders responseHeaders){
  ///      ...
  ///      return "...";
  ///    });
  ///  ```
  ///
  ///  [onReceiveProgress]: The callback to listen downloading progress.
  ///  please refer to [ProgressCallback].
  ///
  ///  [lengthHeader] : The real size of original file (not compressed).
  ///  When file is compressed:
  ///  1. If this value is 'content-length', the `total` argument of `onProgress` will be -1
  ///  2. If this value is not 'content-length', maybe a custom header indicates the original
  ///  file size , the `total` argument of `onProgress` will be this header value.
  ///
  ///  you can also disable the compression by specifying the 'accept-encoding' header value as '*'
  ///  to assure the value of `total` argument of `onProgress` is not -1. for example:
  ///
  ///     await cacheApi.downloadUri(uri, "./example/flutter.svg",
  ///     options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),  // disable gzip
  ///     onProgress: (received, total) {
  ///       if (total != -1) {
  ///        print((received / total * 100).toStringAsFixed(0) + "%");
  ///       }
  ///     });
  Future<ApiResponse> downloadUri(
    Uri uri,
    savePath, {
    ProgressCallback onReceiveProgress,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options options,
  });

  /// Make http request with options.
  ///
  /// [path] The url path.
  /// [data] The request data
  /// [options] The request options.

  Future<ApiResponse<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  });

  /// Make http request with options.
  ///
  /// [uri] The uri.
  /// [data] The request data
  /// [options] The request options.
  Future<ApiResponse<T>> requestUri<T>(
    Uri uri, {
    data,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  });
}

abstract class CacheApiMixin implements CacheApi {
  /// Default Request config. More see [BaseOptions].
  @override
  BaseOptions options;

  /// Each CacheApi instance has a interceptor by which you can intercept requests or responses before they are
  /// handled by `then` or `catchError`. the [interceptor] field
  /// contains a [RequestInterceptor] and a [ResponseInterceptor] instance.
  final Interceptors _interceptors = Interceptors();

  @override
  Interceptors get interceptors => _interceptors;

  @override
  HttpClientAdapter httpClientAdapter;

  @override
  Transformer transformer = DefaultTransformer();

  bool _closed = false;

  static const String _GET = "@GET";
  static const String _POST = "@POST";
  static const String _PUT = "@PUT";
  static const String _PATCH = "@PATCH";

  @override
  void close({bool force = false}) {
    _closed = true;
    httpClientAdapter.close(force: force);
  }

  /// Handy method to make http GET request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
        Duration duration = const Duration(days: 2),
  }) async {
    ApiResponse response;
    try {
      response = await request<T>(
        path,
        queryParameters: queryParameters,
        options: checkOptions('GET', options),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> d = response.data;
        Map<String, dynamic> data = {
          "data": d,
          "initDate": DateTime.now().toString(),
          "expiredTime": duration.inMilliseconds.toString(),
          "url": path+_GET
        };

        box.put(path + _GET, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(path + _GET);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data['data'],
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http GET request, which is a alias of [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> getUri<T>(
    Uri uri, {
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
  }) async {
    ApiResponse response;
    try {
      response = await requestUri<T>(
        uri,
        options: checkOptions('GET', options),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(uri.path + _GET, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(uri.path + _GET);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http POST request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  }) async {
    ApiResponse response;
    try {
      response = await request<T>(
        path,
        data: data,
        options: checkOptions('POST', options),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(path + _POST, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(path + _POST);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http POST request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> postUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
  }) async {
    ApiResponse response;
    try {
      response = await requestUri<T>(
        uri,
        data: data,
        options: checkOptions('POST', options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(uri.path + _POST, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(uri.path + _POST);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http PUT request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
  }) async {
    ApiResponse response;
    try {
      response = await request<T>(
        path,
        data: data,
        options: checkOptions('PUT', options),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(path + _PUT, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(path + _PUT);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http PUT request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> putUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
  }) async {
    ApiResponse response;
    try {
      response = await requestUri<T>(
        uri,
        data: data,
        options: checkOptions('PUT', options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(uri.path + _PUT, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(uri.path + _PUT);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http HEAD request, which is a alias of [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> head<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    bool storeData,
  }) {
    return request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('HEAD', options),
      cancelToken: cancelToken,
    );
  }

  /// Handy method to make http HEAD request, which is a alias of [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> headUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
  }) {
    return requestUri<T>(
      uri,
      data: data,
      options: checkOptions('HEAD', options),
      cancelToken: cancelToken,
    );
  }

  /// Handy method to make http DELETE request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
  }) {
    return request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: checkOptions('DELETE', options),
      cancelToken: cancelToken,
    );
  }

  /// Handy method to make http DELETE request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> deleteUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
  }) {
    return requestUri<T>(
      uri,
      data: data,
      options: checkOptions('DELETE', options),
      cancelToken: cancelToken,
    );
  }

  /// Handy method to make http PATCH request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData,
  }) async {
    ApiResponse response;
    try {
      response = await request<T>(
        path,
        data: data,
        options: checkOptions('PATCH', options),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(path + _PATCH, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(path + _PATCH);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Handy method to make http PATCH request, which is a alias of  [BaseCacheApi.request].
  @override
  Future<ApiResponse<T>> patchUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    bool storeData = false,
  }) async {
    ApiResponse response;
    try {
      response = await requestUri<T>(
        uri,
        data: data,
        options: checkOptions('PATCH', options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (box != null && box.isOpen) {
        Map<String, dynamic> data = response.data;
        box.put(uri.path + _PATCH, json.encode(data));
      }
    } on CacheApiError catch (e) {
      if (storeData && box != null && box.isOpen) {
        String s = box.get(uri.path + _PATCH);
        if (s != null) {
          Map<String, dynamic> data = json.decode(s);
          ApiResponse response1 = new ApiResponse(
              data: data,
              statusCode: e?.response?.statusCode,
              statusMessage: "Data from store");
          return response1;
        }
      }
      throw e;
    }
    return response;
  }

  /// Assure the final future state is succeed!
  @override
  Future<ApiResponse<T>> resolve<T>(response) {
    if (response is! Future) {
      response = Future.value(response);
    }
    return response.then<ApiResponse<T>>((data) {
      return assureResponse<T>(data);
    }, onError: (err) {
      // transform 'error' to 'success'
      return assureResponse<T>(err);
    });
  }

  /// Assure the final future state is failed!
  @override
  Future<ApiResponse<T>> reject<T>(err) {
    if (err is! Future) {
      err = Future.error(err);
    }
    return err.then<ApiResponse<T>>((v) {
      // transform 'success' to 'error'
      throw assureCacheApiError(v);
    }, onError: (e) {
      throw assureCacheApiError(e);
    });
  }

  /// Lock the current CacheApi instance.
  ///
  /// CacheApi will enqueue the incoming request tasks instead
  /// send them directly when [interceptor.request] is locked.
  @override
  void lock() {
    interceptors.requestLock.lock();
  }

  /// Unlock the current CacheApi instance.
  ///
  /// CacheApi instance dequeue the request task。
  @override
  void unlock() {
    interceptors.requestLock.unlock();
  }

  ///Clear the current CacheApi instance waiting queue.
  @override
  void clear() {
    interceptors.requestLock.clear();
  }

  ///  Download the file and save it in local. The default http method is 'GET',
  ///  you can custom it by [Options.method].
  ///
  ///  [urlPath]: The file url.
  ///
  ///  [savePath]: The path to save the downloading file later. it can be a String or
  ///  a callback:
  ///  1. A path with String type, eg 'xs.jpg'
  ///  2. A callback `String Function(HttpHeaders responseHeaders)`; for example:
  ///  ```dart
  ///   await cacheApi.download(url,(HttpHeaders responseHeaders){
  ///      ...
  ///      return '...';
  ///    });
  ///  ```
  ///
  ///  [onReceiveProgress]: The callback to listen downloading progress.
  ///  please refer to [ProgressCallback].
  ///
  /// [deleteOnError] Whether delete the file when error occurs. The default value is [true].
  ///
  ///  [lengthHeader] : The real size of original file (not compressed).
  ///  When file is compressed:
  ///  1. If this value is 'content-length', the `total` argument of `onProgress` will be -1
  ///  2. If this value is not 'content-length', maybe a custom header indicates the original
  ///  file size , the `total` argument of `onProgress` will be this header value.
  ///
  ///  you can also disable the compression by specifying the 'accept-encoding' header value as '*'
  ///  to assure the value of `total` argument of `onProgress` is not -1. for example:
  ///
  ///     await cacheApi.download(url, './example/flutter.svg',
  ///     options: Options(headers: {HttpHeaders.acceptEncodingHeader: '*'}),  // disable gzip
  ///     onProgress: (received, total) {
  ///       if (total != -1) {
  ///        print((received / total * 100).toStringAsFixed(0) + '%');
  ///       }
  ///     });

  @override
  Future<ApiResponse> download(
    String urlPath,
    savePath, {
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options options,
  }) async {
    throw UnsupportedError('Unsupport download API in browser');
  }

  ///  Download the file and save it in local. The default http method is 'GET',
  ///  you can custom it by [Options.method].
  ///
  ///  [uri]: The file url.
  ///
  ///  [savePath]: The path to save the downloading file later. it can be a String or
  ///  a callback:
  ///  1. A path with String type, eg 'xs.jpg'
  ///  2. A callback `String Function(HttpHeaders responseHeaders)`; for example:
  ///  ```dart
  ///   await cacheApi.downloadUri(uri,(HttpHeaders responseHeaders){
  ///      ...
  ///      return '...';
  ///    });
  ///  ```
  ///
  ///  [onReceiveProgress]: The callback to listen downloading progress.
  ///  please refer to [ProgressCallback].
  ///
  ///  [lengthHeader] : The real size of original file (not compressed).
  ///  When file is compressed:
  ///  1. If this value is 'content-length', the `total` argument of `onProgress` will be -1
  ///  2. If this value is not 'content-length', maybe a custom header indicates the original
  ///  file size , the `total` argument of `onProgress` will be this header value.
  ///
  ///  you can also disable the compression by specifying the 'accept-encoding' header value as '*'
  ///  to assure the value of `total` argument of `onProgress` is not -1. for example:
  ///
  ///     await cacheApi.downloadUri(uri, './example/flutter.svg',
  ///     options: Options(headers: {HttpHeaders.acceptEncodingHeader: '*'}),  // disable gzip
  ///     onProgress: (received, total) {
  ///       if (total != -1) {
  ///        print((received / total * 100).toStringAsFixed(0) + '%');
  ///       }
  ///     });
  @override
  Future<ApiResponse> downloadUri(
    Uri uri,
    savePath, {
    ProgressCallback onReceiveProgress,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options options,
  }) {
    return download(
      uri.toString(),
      savePath,
      onReceiveProgress: onReceiveProgress,
      lengthHeader: lengthHeader,
      deleteOnError: deleteOnError,
      cancelToken: cancelToken,
      data: data,
      options: options,
    );
  }

  /// Make http request with options.
  ///
  /// [path] The url path.
  /// [data] The request data
  /// [options] The request options.
  @override
  Future<ApiResponse<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    return _request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Make http request with options.
  ///
  /// [uri] The uri.
  /// [data] The request data
  /// [options] The request options.
  @override
  Future<ApiResponse<T>> requestUri<T>(
    Uri uri, {
    data,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    return request(
      uri.toString(),
      data: data,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<ApiResponse<T>> _request<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    if (_closed) {
      throw CacheApiError(
          error: "CacheApi can't establish new connection after closed.");
    }
    options ??= Options();
    if (options is RequestOptions) {
      data = data ?? options.data;
      queryParameters = queryParameters ?? options.queryParameters;
      cancelToken = cancelToken ?? options.cancelToken;
      onSendProgress = onSendProgress ?? options.onSendProgress;
      onReceiveProgress = onReceiveProgress ?? options.onReceiveProgress;
    }
    var requestOptions = mergeOptions(options, path, data, queryParameters);
    requestOptions.onReceiveProgress = onReceiveProgress;
    requestOptions.onSendProgress = onSendProgress;
    requestOptions.cancelToken = cancelToken;
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }

    bool _isErrorOrException(t) => t is Exception || t is Error;

    // Convert the request/response interceptor to a functional callback in which
    // we can handle the return value of interceptor callback.
    Function _interceptorWrapper(interceptor, bool request) {
      return (data) async {
        var type = request ? (data is RequestOptions) : (data is ApiResponse);
        var lock =
            request ? interceptors.requestLock : interceptors.responseLock;
        if (_isErrorOrException(data) || type) {
          return listenCancelForAsyncTask(
            cancelToken,
            Future(() {
              return checkIfNeedEnqueue(lock, () {
                if (type) {
                  if (!request) data.request = data.request ?? requestOptions;
                  return interceptor(data).then((e) => e ?? data);
                } else {
                  throw assureCacheApiError(data, requestOptions);
                }
              });
            }),
          );
        } else {
          return assureResponse(data, requestOptions);
        }
      };
    }

    // Convert the error interceptor to a functional callback in which
    // we can handle the return value of interceptor callback.
    Function _errorInterceptorWrapper(errInterceptor) {
      return (err) {
        return checkIfNeedEnqueue(interceptors.errorLock, () {
          if (err is! ApiResponse) {
            return errInterceptor(assureCacheApiError(err, requestOptions))
                .then((e) {
              if (e is! ApiResponse) {
                throw assureCacheApiError(e ?? err, requestOptions);
              }
              return e;
            });
          }
          // err is a Response instance
          return err;
        });
      };
    }

    // Build a request flow in which the processors(interceptors)
    // execute in FIFO order.

    // Start the request flow
    Future future;
    future = Future.value(requestOptions);
    // Add request interceptors to request flow
    interceptors.forEach((Interceptor interceptor) {
      future = future.then(_interceptorWrapper(interceptor.onRequest, true));
    });

    // Add dispatching callback to request flow
    future = future.then(_interceptorWrapper(_dispatchRequest, true));

    // Add response interceptors to request flow
    interceptors.forEach((Interceptor interceptor) {
      future = future.then(_interceptorWrapper(interceptor.onResponse, false));
    });

    // Add error handlers to request flow
    interceptors.forEach((Interceptor interceptor) {
      future = future.catchError(_errorInterceptorWrapper(interceptor.onError));
    });

    // Normalize errors, we convert error to the CacheApiError
    return future.then<ApiResponse<T>>((data) {
      return assureResponse<T>(data);
    }).catchError((err) {
      if (err == null || _isErrorOrException(err)) {
        throw assureCacheApiError(err, requestOptions);
      }
      return assureResponse<T>(err, requestOptions);
    });
  }

  // Initiate Http requests
  Future<ApiResponse<T>> _dispatchRequest<T>(RequestOptions options) async {
    var cancelToken = options.cancelToken;
    ResponseBody responseBody;
    try {
      var stream = await _transformData(options);
      responseBody = await httpClientAdapter.fetch(
        options,
        stream,
        cancelToken?.whenCancel,
      );
      responseBody.headers = responseBody.headers ?? {};
      var headers = Headers.fromMap(responseBody.headers ?? {});
      var ret = ApiResponse(
        headers: headers,
        request: options,
        redirects: responseBody.redirects ?? [],
        isRedirect: responseBody.isRedirect,
        statusCode: responseBody.statusCode,
        statusMessage: responseBody.statusMessage,
        extra: responseBody.extra,
      );
      var statusOk = options.validateStatus(responseBody.statusCode);
      if (statusOk || options.receiveDataWhenStatusError) {
        var forceConvert = !(T == dynamic || T == String) &&
            !(options.responseType == ResponseType.bytes ||
                options.responseType == ResponseType.stream);
        String contentType;
        if (forceConvert) {
          contentType = headers.value(Headers.contentTypeHeader);
          headers.set(Headers.contentTypeHeader, Headers.jsonContentType);
        }
        ret.data = await transformer.transformResponse(options, responseBody);
        if (forceConvert) {
          headers.set(Headers.contentTypeHeader, contentType);
        }
      } else {
        await responseBody.stream.listen(null).cancel();
      }
      checkCancelled(cancelToken);
      if (statusOk) {
        return checkIfNeedEnqueue(interceptors.responseLock, () => ret);
      } else {
        throw CacheApiError(
          response: ret,
          error: 'Http status error [${responseBody.statusCode}]',
          type: CacheApiErrorType.RESPONSE,
        );
      }
    } catch (e) {
      throw assureCacheApiError(e, options);
    }
  }

  // If the request has been cancelled, stop request and throw error.
  void checkCancelled(CancelToken cancelToken) {
    if (cancelToken != null && cancelToken.cancelError != null) {
      throw cancelToken.cancelError;
    }
  }

  Future<T> listenCancelForAsyncTask<T>(
      CancelToken cancelToken, Future<T> future) {
    return Future.any([
      if (cancelToken != null)
        cancelToken.whenCancel.then((e) => throw cancelToken.cancelError),
      future,
    ]);
  }

  Future<Stream<Uint8List>> _transformData(RequestOptions options) async {
    var data = options.data;
    List<int> bytes;
    Stream<List<int>> stream;
    if (data != null &&
        ['POST', 'PUT', 'PATCH', 'DELETE'].contains(options.method)) {
      // Handle the FormData
      int length;
      if (data is Stream) {
        assert(data is Stream<List>,
            'Stream type must be `Stream<List>`, but ${data.runtimeType} is found.');
        stream = data;
        options.headers.keys.any((String key) {
          if (key.toLowerCase() == Headers.contentLengthHeader) {
            length = int.parse(options.headers[key].toString());
            return true;
          }
          return false;
        });
      } else if (data is FormData) {
        if (data is FormData) {
          options.headers[Headers.contentTypeHeader] =
              'multipart/form-data; boundary=${data.boundary}';
        }
        stream = data.finalize();
        length = data.length;
      } else {
        // Call request transformer.
        var _data = await transformer.transformRequest(options);
        if (options.requestEncoder != null) {
          bytes = options.requestEncoder(_data, options);
        } else {
          //Default convert to utf8
          bytes = utf8.encode(_data);
        }
        // support data sending progress
        length = bytes.length;

        var group = <List<int>>[];
        const size = 1024;
        var groupCount = (bytes.length / size).ceil();
        for (var i = 0; i < groupCount; ++i) {
          var start = i * size;
          group.add(bytes.sublist(start, math.min(start + size, bytes.length)));
        }
        stream = Stream.fromIterable(group);
      }

      if (length != null) {
        options.headers[Headers.contentLengthHeader] = length.toString();
      }
      var complete = 0;
      var byteStream =
          stream.transform<Uint8List>(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          if (options.cancelToken != null && options.cancelToken.isCancelled) {
            sink
              ..addError(options.cancelToken.cancelError)
              ..close();
          } else {
            sink.add(Uint8List.fromList(data));
            if (length != null) {
              complete += data.length;
              if (options.onSendProgress != null) {
                options.onSendProgress(complete, length);
              }
            }
          }
        },
      ));
      if (options.sendTimeout > 0) {
        byteStream.timeout(Duration(milliseconds: options.sendTimeout),
            onTimeout: (sink) {
          sink.addError(CacheApiError(
            request: options,
            error: 'Sending timeout[${options.connectTimeout}ms]',
            type: CacheApiErrorType.SEND_TIMEOUT,
          ));
          sink.close();
        });
      }
      return byteStream;
    } else {
      options.headers.remove(Headers.contentTypeHeader);
    }
    return null;
  }

  RequestOptions mergeOptions(
      Options opt, String url, data, Map<String, dynamic> queryParameters) {
    var query = (Map<String, dynamic>.from(options.queryParameters ?? {}))
      ..addAll(queryParameters ?? {});
    final optBaseUrl = (opt is RequestOptions) ? opt.baseUrl : null;
    final optConnectTimeout =
        (opt is RequestOptions) ? opt.connectTimeout : null;
    return RequestOptions(
      method: (opt.method ?? options.method)?.toUpperCase() ?? 'GET',
      headers: (Map.from(options.headers))..addAll(opt.headers),
      baseUrl: optBaseUrl ?? options.baseUrl ?? '',
      path: url,
      data: data,
      connectTimeout: optConnectTimeout ?? options.connectTimeout ?? 0,
      sendTimeout: opt.sendTimeout ?? options.sendTimeout ?? 0,
      receiveTimeout: opt.receiveTimeout ?? options.receiveTimeout ?? 0,
      responseType:
          opt.responseType ?? options.responseType ?? ResponseType.json,
      extra: (Map.from(options.extra))..addAll(opt.extra),
      contentType:
          opt.contentType ?? options.contentType ?? Headers.jsonContentType,
      validateStatus: opt.validateStatus ??
          options.validateStatus ??
          (int status) {
            return status >= 200 && status < 300;
          },
      receiveDataWhenStatusError: opt.receiveDataWhenStatusError ??
          options.receiveDataWhenStatusError ??
          true,
      followRedirects: opt.followRedirects ?? options.followRedirects ?? true,
      maxRedirects: opt.maxRedirects ?? options.maxRedirects ?? 5,
      queryParameters: query,
      requestEncoder: opt.requestEncoder ?? options.requestEncoder,
      responseDecoder: opt.responseDecoder ?? options.responseDecoder,
    );
  }

  Options checkOptions(method, options) {
    options ??= Options();
    options.method = method;
    return options;
  }

  FutureOr checkIfNeedEnqueue(Lock lock, EnqueueCallback callback) {
    if (lock.locked) {
      return lock.enqueue(callback);
    } else {
      return callback();
    }
  }

  CacheApiError assureCacheApiError(err, [RequestOptions requestOptions]) {
    CacheApiError cacheApiError;
    if (err is CacheApiError) {
      cacheApiError = err;
    } else {
      cacheApiError = CacheApiError(error: err);
    }
    cacheApiError.request = cacheApiError.request ?? requestOptions;
    return cacheApiError;
  }

  ApiResponse<T> assureResponse<T>(response, [RequestOptions requestOptions]) {
    if (response is ApiResponse<T>) {
      response.request = response.request ?? requestOptions;
    } else if (response is! ApiResponse) {
      response = ApiResponse<T>(data: response, request: requestOptions);
    } else {
      T data = response.data;
      response = ApiResponse<T>(
        data: data,
        headers: response.headers,
        request: response.request,
        statusCode: response.statusCode,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        statusMessage: response.statusMessage,
      );
    }
    return response;
  }

  @override
  Future<void> init() async {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    box = await Hive.openBox("SMART_DIO");
    var keys = [];
    for (int i = 0; i < box.length; i++) {
      Map<String, dynamic> data = json.decode(box.getAt(i));
      DateTime now = DateTime.now();
      DateTime initDate = DateTime.parse(data['initDate']);
      Duration duration =
      Duration(milliseconds: int.parse(data['expiredTime']));
      if(now.difference(initDate)> duration){
        keys.add(data['url']);
      }
    }
    box.deleteAll(keys);
  }
}

