class Endpoints {
  String recentReportsUrl;
  String browseWavesUrl;
  String signInUrl;
  String signUpUrl;
  String forgotPasswordUrl;
  String recommendationUrl;
  String latestAppVersion;
  String supportRequestUrl;
  String privacyPolicyUrl;

  Endpoints({this.recentReportsUrl, this.browseWavesUrl, this.signInUrl,
      this.signUpUrl, this.forgotPasswordUrl, this.recommendationUrl,
      this.latestAppVersion, this.supportRequestUrl, this.privacyPolicyUrl});


  factory Endpoints.fromJson(Map<String, dynamic> json) {
    return Endpoints(
        recentReportsUrl: json['recentReportsUrl'],
        browseWavesUrl: json['browseWavesUrl'],
        signInUrl: json['signInUrl'],
        signUpUrl: json['signUpUrl'],
        forgotPasswordUrl: json['forgotPasswordUrl'],
        recommendationUrl: json['recommendationUrl'],
        latestAppVersion: json['latestAppVersion'],
        supportRequestUrl: json['supportRequestUrl'],
        privacyPolicyUrl: json['privacyPolicyUrl'],
    );
  }
}