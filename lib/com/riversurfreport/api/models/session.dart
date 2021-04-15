class Session {
  String token;
  String AWSAccessKeyID;
  String AWSSecretAccessKey;

  Session({this.token, this.AWSAccessKeyID, this.AWSSecretAccessKey});


  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: json['token'],
      AWSAccessKeyID: json['AWSAccessKeyID'],
      AWSSecretAccessKey: json['AWSSecretAccessKey']
    );
  }
}