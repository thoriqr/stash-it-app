import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/user_profile_response.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String? baseUrl}) = _ProfileApi;

  @GET('/users/me')
  Future<GetUserResponse> getUser();
}
