import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
