class Result<T> {
  T? data;
  String? message;
  ResultType resultType;

  Result({this.data, this.message, required this.resultType});
}

enum ResultType { success, error }
