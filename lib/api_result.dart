sealed class ApiResult <T>{
  const ApiResult();
}



final class Loading<T> extends ApiResult<T>{
  const Loading();
}

final class Success<T> extends ApiResult<T>{
  final T data;

  const Success(this.data);
}


final class Failure<T> extends ApiResult<T>{
  final String message;

  const Failure(this.message);
}