import 'package:dio/dio.dart';

// ignore: avoid_dynamic_calls
class DioApiService {
  Dio dio;

  DioApiService({required this.dio});

  // ignore: avoid-dynamic
  Future<dynamic> getRequest(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } on DioError catch (err) {
      _returnDioErrorResponse(err);
    }
  }

  // ignore: avoid-dynamic
  Future<dynamic> postRequest(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } on DioError catch (err) {
      _returnDioErrorResponse(err);
    }
  }

  CustomException _returnDioErrorResponse(DioError error) {
    var message = error.response?.data?['error'];
    if (error.type == DioErrorType.receiveTimeout) {
      throw FetchDataException('Error connection timeout');
    }
    switch (error.response?.statusCode) {
      case 400:
        throw BadRequestException(
          message ?? error.response!.statusMessage ?? 'Bad request',
        );
      case 401:
        throw UnauthorisedException(
          message ?? 'Unauthorised request: ${error.response!.statusCode}',
        );
      case 403:
        throw UnauthorisedException(
          message ?? 'Access forbidden: ${error.response!.statusCode}',
        );
      case 404:
        throw FetchDataException(
          message ?? 'Api not found: ${error.response!.statusCode}',
        );
      case 500:
      default:
        throw FetchDataException(
          message ?? 'Error occurred while Communication with Server ',
        );
    }
  }
}

class CustomException implements Exception {
  final String? message;
  final String? prefix;

  CustomException([this.message, this.prefix]);

  @override
  String toString() {
    return '$message';
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super(message, 'Error During Communication: ');
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, 'Invalid Input: ');
}
