import 'package:dio/dio.dart';

import '../../../core/error/api_failure_mapper.dart';
import '../domain/user_profile.dart';
import 'datasources/profile_api.dart';
import 'profile_mapper.dart';

class ProfileRepository {
  const ProfileRepository({required this.api});

  final ProfileApi api;

  Future<UserProfile> getUser() async {
    try {
      final response = await api.getUser();
      return profileFrom(response.data.user);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
