class AppRequest {
  static Map<String, String> header([String? bearerToken]) {
    if (bearerToken != null) {
      return {
        'Accept': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };
    } else {
      return {
        'Accept': 'application/json',
      };
    }
  }
}
