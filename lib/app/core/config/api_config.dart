class AppUrl {
  AppUrl._();

  static const String _serverUrl = 'https://api.letsridee.com';


  static const String baseUrl = "$_serverUrl/v1";



  static const Duration receiveTimeout = Duration(seconds: 60);


  static const Duration connectionTimeout = Duration(seconds: 60);

  static const String  login= '/users';

}
