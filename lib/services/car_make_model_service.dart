import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tagalong/util/log.dart' as logger;

class CarMakeModelService {

  // TODO: The REST API token should be encrypted or hidden?
  final String _apiToken = 'bE6g4vzFSz57rjH8D4ipn8cTKL6o6HOnV8VeowYo37xyFoQgeAfIMpsrS8EI';


  /// Exposes a List<String> of `Make` values.
  Future<List<String>> getMakes() async {

    List<String> makeList = [];

    // Get response
    Uri makesUrl = Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/all/makes?api_token=$_apiToken');
    http.Response response = await http.get(makesUrl);

    // Response was OK
    if (response.statusCode == 200) {
      var makes = jsonDecode(response.body) as List;

      // Parse {"make": ,<make>} objects into a List<String>
      makeList = makes.map((make) => make['make'] as String).toList();
      print('Make List: $makeList');
    }

    // Response was NOT OK
    else {

    }
    return makeList;
  }


  /// Exposes a List<String> of `Model` values.
  Future<List<String>> getModels({required String make}) async {

    List<String> modelList = [];

    // Get response based on [make]
    Uri modelUrl = Uri.parse("https://carmakemodeldb.com/api/v1/car-lists/get/all/models/$make?api_token=$_apiToken");
    http.Response response = await http.get(modelUrl);

    // Response was OK
    if (response.statusCode == 200) {
      var models = jsonDecode(response.body) as List;

      // Parse {"model": <model>} objects into List<String>
      modelList = models.map((model) => model['model'] as String).toList();
      print('Model List for $make: $modelList');
    }


    // Response was NOT OK
    else {

    }

    return modelList;
  }


  /// Exposes a List<String> of `year` values.
  Future<List<String>> getYears({required String make, required String model}) async {
    List<String> yearList = [];

    // Get response
    Uri yearUrl = Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/year-range/$make/$model?api_token=$_apiToken');
    http.Response response = await http.get(yearUrl);

    // Response was OK
    if (response.statusCode == 200) {
      var years = jsonDecode(response.body) as List;

      // Parse {"year: <year>} objects into List<String>
      yearList = years.map((year) => year['year'] as String).toList();
      print('Year List for $make, $model: $yearList');
    }

    // Response was NOT OK
    else {

    }

    return yearList;
  }

}

