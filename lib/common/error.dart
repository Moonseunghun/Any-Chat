import 'dart:async';

import 'package:anychat/common/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/util_state.dart';

class CustomException implements Exception {
  final String message;

  CustomException(this.message);

  @override
  String toString() => message;
}

class Error {
  final Exception exception;
  final StackTrace? stackTrace;
  final int? statusCode;

  Error(this.exception, {this.stackTrace, this.statusCode});

  @override
  String toString() => exception.toString();

  handleError({String? message, Function? errorHandler}) {
    if (statusCode == 401) {
      errorToast(message: '로그인 정보가 만료되었습니다. \n로그인 페이지로 이동합니다.');
    } else if (errorHandler != null) {
      errorHandler(this);
    } else {
      errorToast(
          message: exception.runtimeType == CustomException
              ? toString()
              : statusCode == 401
                  ? '로그인 정보가 만료되었습니다. \n로그인 페이지로 이동합니다.'
                  : message ?? '예상치 못한 오류가 발생했습니다');
    }

    throw this;
  }
}

extension FutureExtension<T> on Future<T> {
  Future<R> run<R>(WidgetRef ref, FutureOr<R> Function(T) onValue,
      {String? errorMessage, Function(Error)? errorHandler}) async {
    ref.read(loadingProvider.notifier).on();
    return await then((result) {
      ref.read(loadingProvider.notifier).off();
      return onValue(result);
    }).catchError((e, s) {
      ref.read(loadingProvider.notifier).off();
      return (e as Error).handleError(message: errorMessage, errorHandler: errorHandler);
    });
  }
}
