import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  Future<String> checkNetworkConnection() async {
    // Check the current connectivity status of the device
    var connectivityResult = await (Connectivity().checkConnectivity());

    // connectivityResult returns a list of connection types in connectivity_plus v7
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return "Network Status: Connected to Cellular Mobile Data";
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return "Network Status: Connected to Local Wi-Fi Network";
    } else {
      return "Network Status: Offline - No Internet Connection";
    }
  }
}