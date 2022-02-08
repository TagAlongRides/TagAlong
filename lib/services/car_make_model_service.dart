import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tagalong/util/log.dart' as logger;

class CarMakeModelService {

  // TODO: The REST API token should be encrypted or hidden?
  final String _apiToken = 'bE6g4vzFSz57rjH8D4ipn8cTKL6o6HOnV8VeowYo37xyFoQgeAfIMpsrS8EI';
  late String make;
  late String model;
  late String year;
  late String color;

  /// Exposes a List<String> of Make values.
  Future<List<String>?> getMakes() async {

    // Get response
    Uri makesUrl = Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/all/makes?api_token=$apiToken');
    http.Response response = await http.get(makesUrl);

    // Response was OK
    if (response.statusCode == 200) {
      String jsonStringData = response.body;
      var makes = jsonDecode(jsonStringData) as List;
      List<String> makeList = makes.map((make) => make['make'] as String).toList();
      print('Make List: $makeList');
    }
    return null;
  }

}

