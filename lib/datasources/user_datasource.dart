import 'package:dartz/dartz.dart';
import 'package:laundry_app_flutter/config/app_constants.dart';
import 'package:laundry_app_flutter/config/app_request.dart';
import 'package:laundry_app_flutter/config/app_response.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:http/http.dart' as http;

class UserDataSource {
  static Future<Either<Failure, Map>> register(
    String name,
    String email,
    String password,
  ) async {
    Uri url = Uri.parse('${AppConstants.baseUrl}/register');

    try {
      final response = await http.post(
        url,
        headers: AppRequest.header(),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = AppResponse.data(response);

      return Right(data);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }

      return Left(
        FetchFailure(
          e.toString(),
        ),
      );
    }
  }
}
