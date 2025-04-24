class AppUrl {
  AppUrl._();

  static const String _serverUrl = 'https://qrbuddyapi.in';


  static const String baseUrl = "$_serverUrl/v3/api";

  //  static const String users = '/users';



  static const Duration receiveTimeout = Duration(seconds: 60);


  static const Duration connectionTimeout = Duration(seconds: 60);

  static const String  login= '/users';

}
