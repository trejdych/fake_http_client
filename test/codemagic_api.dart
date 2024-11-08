import 'package:dio/dio.dart';

import 'har/json_placeholder_api.dart';

class CodemagicApi {
  static const String baseUrl = 'https://api.codemagic.io';
  final dio = Dio();

  Future<Response<JSON>> getApps() async {
    final response = await dio.get<JSON>(
      '$baseUrl/apps',
    );

    return response;
  }

  Future<Response<JSON>> getBuilds() async {
    final response = await dio.get<JSON>(
      '$baseUrl/builds',
    );

    return response;
  }

  Future<Response<JSON>> getBuild(String buildId) async {
    final response = await dio.get<JSON>(
      '$baseUrl/builds/$buildId',
    );

    return response;
  }

  Future<Response<JSON>> runBuild({
    required String appId,
    required String workflowId,
    required String branch,
  }) async {
    final response = await dio.post<JSON>(
      '$baseUrl/builds',
      data: {
        'appId': appId,
        'workflowId': workflowId,
        'branch': branch,
      },
    );

    return response;
  }
}
