class GetTokenResponse {
  final String data;
  final String message;

  GetTokenResponse({this.data, this.message});

  factory GetTokenResponse.fromJson(Map<String, dynamic> json) {
    return GetTokenResponse(data: json['data'], message: json['message']);
  }
}
