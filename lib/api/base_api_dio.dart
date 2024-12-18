import 'dart:io' as io;
import 'dart:ui';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

ApiInitializer? _initializer;
Map<String, Function> _deserializers = {};

dynamic _dummyDeserializer(dynamic data) {
  return data;
}

Function? _findDeserializerByTypeName(String typeName) {
  if (typeName.startsWith('Map<')) {
    return _dummyDeserializer;
  }
  return _deserializers[typeName];
}

void initApis<T extends BaseApiDio, TDeserializer>(
  ApiInitializer<T, TDeserializer> initializer,
) {
  _initializer = initializer;
  for (var deserializer in initializer.modelDeserializers.entries) {
    final typeKey = deserializer.key.toString();
    _deserializers[typeKey] = deserializer.value;
  }
}

T api<T extends BaseApiDio>() {
  return _initializer!._findApi<T>();
}

class ApiInitializer<T extends BaseApiDio, TDeserializer> {
  List<T> apis;
  Map<TDeserializer, Function> modelDeserializers;

  T _findApi<T>() {
    return apis.firstWhere((a) => a.runtimeType == T) as T;
  }

  ApiInitializer({
    required this.apis,
    required this.modelDeserializers,
  });
}

class ContentTypeHeaders {
  static const String MULTIPART_FORM_DATA = 'multipart/form-data';
  static const String APPLICATION_JSON = 'application/json';
}

class AcceptHeaders {
  static const String APPLICATION_JSON = 'application/json';
}

class BaseApiDio {
  final String baseApiUrl;
  final int timeoutMillis;

  BaseApiDio({
    required this.baseApiUrl,
    this.timeoutMillis = 60000,
  });

  static final List<CancelToken> _cancelTokens = [];

  static void _cancelAllRequests() {
    if (kDebugMode) {
      print('CANCELLING ALL REQUESTS');
    }
    _cancelTokens.forEach((CancelToken cancelToken) {
      cancelToken.cancel();
    });
    _cancelTokens.clear();
  }

  void cancelAllRequests() {
    _cancelAllRequests();
  }

  static void cancelAllRequestsStatic() {
    _cancelAllRequests();
  }

  CancelToken get _newCancelToken {
    final token = CancelToken();
    _cancelTokens.add(token);
    return token;
  }

  void _removeCancelToken(CancelToken cancelToken) {
    _cancelTokens.remove(cancelToken);
  }

  Map<String, dynamic> _normalMapToFormMap(
    Map body,
  ) {
    Map<String, dynamic> map = {};
    body.forEach((key, value) {
      dynamic formValue;

      if (value is Uint8List) {
        // print("toFormDataMap value is Uint8List");
        formValue = dio.MultipartFile.fromBytes(
          value,
        );
      } else if (value is List<int>) {
        // print("toFormDataMap value is List<int>");
        formValue = dio.MultipartFile.fromBytes(
          value,
        );
      } else if (value is DateTime) {
        formValue = value.toIso8601String();
      } else {
        formValue = value;
      }
      if (formValue != null) {
        map[key.toString()] = formValue;
      }
    });
    return map;
  }

  /// can be overrided completely
  /// or you can pass custom interceptors with each request
  @protected
  List<dio.Interceptor> getInterceptors() {
    final interceptors = [
      DioMainInterceptor(
        contentType: ContentTypeHeaders.APPLICATION_JSON,
      ),
    ];

    return interceptors;
  }

  /// e.g. if it's a List with a generic type it will return
  /// the name of the generic
  String _getTypeName<T>() {
    return T.toString().replaceAll('?', '');
  }

  T? _deserializeResponse<T>(
    Response<dynamic> response,
    bool loadAsBytes,
    Type? genericType,
  ) {
    final success = response.statusCode == 200 ||
        response.statusCode == 304 ||
        response.statusCode == 204;

    if (T == bool) {
      return success as T;
    }

    final typeName = _getTypeName<T>();

    if (success) {
      if (loadAsBytes && response.data is List<int>) {
        return response.data as T;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (T == bool) {
          return true as T;
        }
        final deserializer = _findDeserializerByTypeName(typeName);
        if (deserializer == null) {
          throw 'No deserializer found for $T';
        }
        return deserializer.call(map) as T;
      } else if (response.data is List) {
        final list = response.data as List;
        if (genericType != null) {
          final deserializer = _findDeserializerByTypeName(
            genericType.toString(),
          );
          final data = list.map((e) => deserializer!(e)).toList();
          return data as T;
        }

        return response.data as T;
      }
      if (response.data is num) {
        return response.data as T;
      } else if (response.data is T) {
        return response.data as T;
      }
    }
    return null;
  }

  /// [path] full path without base url e.g. /mobile/api/v1/...
  /// [body] request body
  /// [errorCallback] passed to interceptor and called on errors
  /// [onSendProgress] if passed, can report upload progress
  /// [optionalHeaders] these headers will be added to a request via
  /// interceptor
  /// [files] files to send via form data (if backend api requires this way)
  /// [requestInterceptors] you can substitute the default interceptors by
  /// custom ones if necessary. These interceptors will completely replace
  /// all custom for the current request
  /// [contentType] application/json or multipart/form-data
  Future<T?> post<T>({
    required String path,
    Map? body,
    ErrorCallback? errorCallback,
    dio.ProgressCallback? onSendProgress,
    Map<String, dynamic>? optionalHeaders,
    List<MapEntry<String, dio.MultipartFile>>? files,
    List<dio.Interceptor>? requestInterceptors,
    String contentType = ContentTypeHeaders.APPLICATION_JSON,
    bool canUseCacheInterceptor = true,
    Type? genericType,
  }) async {
    return _sendRequestWithBody<T>(
      path: path,
      body: body,
      contentType: contentType,
      canUseCacheInterceptor: canUseCacheInterceptor,
      errorCallback: errorCallback,
      method: 'POST',
      onSendProgress: onSendProgress,
      optionalHeaders: optionalHeaders,
      files: files,
      requestInterceptors: requestInterceptors,
      genericType: genericType,
    );
  }

  /// [path] full path without base url e.g. /mobile/api/v1/...
  /// [firstQuestionData] request body
  /// [errorCallback] passed to interceptor and called on errors
  /// [optionalHeaders] these headers will be added to a request via
  /// interceptor
  /// [platformFiles] files to send via form data (if backend api requires this way)
  /// [requestInterceptors] you can substitute the default interceptors by
  /// custom ones if necessary. These interceptors will completely replace
  /// all custom for the current request
  /// [contentType] application/json or multipart/form-data
  Future<T?> get<T>({
    required String path,
    bool canUseCacheInterceptor = true,
    ErrorCallback? errorCallback,
    String contentType = ContentTypeHeaders.APPLICATION_JSON,
    Map<String, dynamic>? optionalHeaders,
    List<dio.Interceptor>? requestInterceptors,
    bool isSecure = true,
    Type? genericType,
  }) async {
    return _sendBodylessRequest<T>(
      path: path,
      method: 'GET',
      canUseCacheInterceptor: canUseCacheInterceptor,
      contentType: contentType,
      errorCallback: errorCallback,
      optionalHeaders: optionalHeaders,
      requestInterceptors: requestInterceptors,
      isSecure: isSecure,
      genericType: genericType,
    );
  }

  Future<T?> delete<T>({
    required String path,
    Map? body,
    ErrorCallback? errorCallback,
    dio.ProgressCallback? onSendProgress,
    Map<String, dynamic>? optionalHeaders,
    List<dio.Interceptor>? requestInterceptors,
    String contentType = ContentTypeHeaders.APPLICATION_JSON,
    bool canUseCacheInterceptor = true,
    Type? genericType,
  }) async {
    return _sendRequestWithBody<T>(
      path: path,
      method: 'DELETE',
      body: body,
      contentType: contentType,
      canUseCacheInterceptor: canUseCacheInterceptor,
      errorCallback: errorCallback,
      onSendProgress: onSendProgress,
      optionalHeaders: optionalHeaders,
      requestInterceptors: requestInterceptors,
      genericType: genericType,
    );
  }

  Future<T?> _sendRequestWithBody<T>({
    required String path,
    Map? body,
    required String method,
    required String contentType,
    required ErrorCallback? errorCallback,
    required bool canUseCacheInterceptor,
    dio.ProgressCallback? onSendProgress,
    Map<String, dynamic>? optionalHeaders,
    List<MapEntry<String, dio.MultipartFile>>? files,
    required List<dio.Interceptor>? requestInterceptors,
    Type? genericType,
  }) async {
    final loadAsBytes = T == Uint8List;
    dio.Response response;
    dio.BaseOptions baseOptions = dio.BaseOptions(
      baseUrl: baseApiUrl,
      connectTimeout: Duration(
        milliseconds: timeoutMillis,
      ),
      receiveTimeout: Duration(
        milliseconds: timeoutMillis,
      ),
      method: method,
    );
    final String url = '$baseApiUrl$path';
    var cancelToken = _newCancelToken;

    if (kDebugMode) {
      print('REQUEST url: ${method} ${url}');
      print('REQUEST header: ${optionalHeaders}');
      print('REQUEST body: ${body}');
    }
    try {
      FormData? formData;
      Map<String, dynamic>? bodyAsMap;
      final sendAsFormData =
          contentType == ContentTypeHeaders.MULTIPART_FORM_DATA;
      if (body != null) {
        bodyAsMap = _normalMapToFormMap(body);

        if (sendAsFormData) {
          formData = dio.FormData.fromMap(bodyAsMap);
        }
        if (files?.isNotEmpty == true && formData != null) {
          formData.files.addAll(files!);
        }
      }
      final interceptors = requestInterceptors ?? getInterceptors();
      interceptors.forEach((interceptor) {
        if (interceptor is DioMainInterceptor) {
          interceptor.errorCallback = errorCallback;
          interceptor.contentType = contentType;
        }
      });

      final api = dio.Dio(baseOptions);
      api.acceptSelfSignedCertificate();
      api.interceptors.addAll(interceptors);
      if (optionalHeaders != null) {
        api.options.extra.addAll(optionalHeaders);
      }
      final data = sendAsFormData ? formData : bodyAsMap;
      response = await api.request(
        path,
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (e, s) {
      _removeCancelToken(cancelToken);
      _processException(e, s, url);
      if (T == bool) {
        return false as T;
      }
      return null;
    }
    _removeCancelToken(cancelToken);

    return _deserializeResponse<T>(
      response,
      loadAsBytes,
      genericType,
    );
  }

  Future<T?> _sendBodylessRequest<T>({
    required String path,
    required String method,
    required String contentType,
    required ErrorCallback? errorCallback,
    required bool canUseCacheInterceptor,
    dio.ProgressCallback? onSendProgress,
    Map<String, dynamic>? optionalHeaders,
    required List<dio.Interceptor>? requestInterceptors,
    bool isSecure = true,
    Type? genericType,
  }) async {
    final loadAsBytes = T == Uint8List;
    dio.Response response;
    dio.BaseOptions baseOptions = dio.BaseOptions(
      baseUrl: baseApiUrl,
      connectTimeout: Duration(
        milliseconds: timeoutMillis,
      ),
      receiveTimeout: Duration(
        milliseconds: timeoutMillis,
      ),
      method: method,
      responseType:
          loadAsBytes ? dio.ResponseType.bytes : dio.ResponseType.json,
    );
    final String url = '$baseApiUrl$path';
    var cancelToken = _newCancelToken;
    try {
      var interceptors = requestInterceptors ?? getInterceptors();
      interceptors.forEach((interceptor) {
        if (interceptor is DioMainInterceptor) {
          interceptor.errorCallback = errorCallback;
          interceptor.contentType = contentType;
          interceptor.addAuthenticationHeaders = isSecure;
        }
      });

      final api = dio.Dio(baseOptions);
      api.acceptSelfSignedCertificate();
      api.interceptors.addAll(interceptors);

      if (optionalHeaders != null) {
        api.options.extra.addAll(optionalHeaders);
      }

      response = await api.request(
        url,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (e, s) {
      _removeCancelToken(cancelToken);
      _processException(e, s, url);
      if (T == bool) {
        return false as T;
      }
      return null;
    }
    _removeCancelToken(cancelToken);
    return _deserializeResponse<T>(
      response,
      loadAsBytes,
      genericType,
    );
  }

  void _processException(
    Object e,
    StackTrace stackTrace,
    String url,
  ) {
    if (e is dio.DioException) {
      if (e.response?.data is Map) {
        var errorData = {...e.response!.data as Map};
        errorData['url'] = url;
        onError(errorData);
      } else {
        var value = e.response?.statusMessage ?? e.message;
        onError({
          'error': value,
          'url': url,
        });
      }
    } else {
      var value = e.toString();
      onError({
        'error': value,
        'url': url,
      });
    }
  }

  void onError(Map? error) {
    print('error: $error');
  }
}

/// этот интерсептор всегда должен добавляться в запросы
/// в нем подставляются данные для авторизации и обрабатываются
/// ошибки дубликатов, восставноеления аккаунтов и т.п.
class DioMainInterceptor extends dio.InterceptorsWrapper {
  ErrorCallback? errorCallback;
  String contentType;
  String? bearerToken;
  bool addAuthenticationHeaders = true;

  String _uuid = '';
  // static bool _isLoggingOut = false;

  DioMainInterceptor({
    this.errorCallback,
    this.bearerToken,
    required this.contentType,
  });

  @override
  Future onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    if (addAuthenticationHeaders) {
      final isCanceled = options.cancelToken?.isCancelled == true;

      ///print('TOKEN: STATE ${options.cancelToken?.isCancelled}');
      if (isCanceled) {
        return handler.reject(_buildSilentError(options));
      }
    }

    options.headers[io.HttpHeaders.acceptHeader] = 'application/json';
    options.headers[io.HttpHeaders.contentTypeHeader] = contentType;
    if (options.extra.isNotEmpty) {
      options.extra.forEach((key, value) {
        options.headers[key] = options.extra[key];
      });
    }
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) async {
    try {
      dynamic data = response.data;
      final statusCode = response.statusCode;

      if (kDebugMode) {
        print('RESPONSE statusCode: $statusCode');
        print('RESPONSE data: $data');
      }
    } catch (e) {
      print(e);
    }

    return super.onResponse(
      response,
      handler,
    );
  }

  @override
  Future onError(
    dio.DioException error,
    dio.ErrorInterceptorHandler handler,
  ) async {
    dio.RequestOptions? options = error.response?.requestOptions;
    if (kDebugMode) {
      print('RESPONSE error statusCode: ${error.response?.statusCode}');
      print('RESPONSE error data: ${error.response?.data}');
    }
    return super.onError(
      error,
      handler,
    );
  }

  dio.DioException _buildSilentError(
    RequestOptions requestOptions,
  ) {
    return dio.DioException(
      error: '{}',
      requestOptions: requestOptions,
    );
  }
}

extension _DioExtension on dio.Dio {
  void acceptSelfSignedCertificate() {
    if (!kIsWeb) {
      final adapter = this.httpClientAdapter as IOHttpClientAdapter;
      (
        createHttpClient: () {
          // Don't trust any certificate just because their root cert is trusted.
          final io.HttpClient client = io.HttpClient(
              context: io.SecurityContext(withTrustedRoots: false));
          // You can test the intermediate / root cert here. We just ignore it.
          client.badCertificateCallback =
              ((io.X509Certificate cert, String host, int port) => true);
          return client;
        },
      );
    }
  }
}
