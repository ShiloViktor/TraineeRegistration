import 'dart:convert';

class SignUpResponse {
  final String message;
  final String data;

  SignUpResponse({this.message, this.data});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      message: json['message'],
      data: json['data'],
    );
  }
}
