import 'package:dartz/dartz.dart';
import 'package:laundry_app_flutter/config/app_constants.dart';
import 'package:laundry_app_flutter/config/app_request.dart';
import 'package:laundry_app_flutter/config/app_response.dart';
import 'package:laundry_app_flutter/config/app_session.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:http/http.dart' as http;
import 'package:laundry_app_flutter/models/user_model.dart';

class LaundryDatasource {
  static Future<Either<Failure, Map>> readByUser(int userId) async {
    Uri url = Uri.parse('${AppConstants.baseUrl}/laundry/user/$userId');
    final token = await AppSession.getBearerToken();

    try {
      final response = await http.get(
        url,
        headers: AppRequest.header(token),
      );

      final data = AppResponse.data(response);

      return Right(data);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }

      return Left(FetchFailure(e.toString()));
    }
  }

  static Future<Either<Failure, Map>> claim(String id, String claimCode) async {
    Uri url = Uri.parse('${AppConstants.baseUrl}/laundry/claim');
    final token = await AppSession.getBearerToken();
    UserModel? user = await AppSession.getUser();

    try {
      final response = await http.post(
        url,
        headers: AppRequest.header(token),
        body: {
          'id': id,
          'claim_code': claimCode,
          'user_id': user!.id.toString(),
        },
      );

      final data = AppResponse.data(response);

      return Right(data);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }

      return Left(FetchFailure(e.toString()));
    }
  }
}
