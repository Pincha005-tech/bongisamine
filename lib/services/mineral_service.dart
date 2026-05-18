import '../coree/api/api_client.dart';
import '../models/mineral_model.dart';
import '../models/paginated_response.dart';

class MineralService {
  MineralService._();

  static Future<List<MineralModel>> list() async {
    final data = await ApiClient.get('/minerals/');
    return (data as List)
        .map((e) => MineralModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<PaginatedResponse<MineralModel>> paginated({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await ApiClient.get(
      '/minerals/paginated',
      query: {'page': '$page', 'limit': '$limit'},
    );
    return PaginatedResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
      MineralModel.fromJson,
    );
  }

  static Future<MineralModel> create(MineralModel mineral) async {
    final data =
        await ApiClient.post('/minerals/', body: mineral.toCreateJson());
    return MineralModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
