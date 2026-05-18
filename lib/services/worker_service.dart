import '../coree/api/api_client.dart';
import '../models/paginated_response.dart';
import '../models/worker_model.dart';

class WorkerService {
  WorkerService._();

  static Future<List<WorkerModel>> list() async {
    final data = await ApiClient.get('/workers/');
    return (data as List)
        .map((e) => WorkerModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<PaginatedResponse<WorkerModel>> paginated({
    int page = 1,
    int limit = 50,
  }) async {
    final data = await ApiClient.get(
      '/workers/paginated',
      query: {'page': '$page', 'limit': '$limit'},
    );
    return PaginatedResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
      WorkerModel.fromJson,
    );
  }

  static Future<WorkerModel> getById(int id) async {
    final data = await ApiClient.get('/workers/$id');
    return WorkerModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<WorkerModel> create(WorkerModel worker) async {
    final data =
        await ApiClient.post('/workers/', body: worker.toCreateJson());
    return WorkerModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<WorkerModel> update(int id, WorkerModel worker) async {
    final data = await ApiClient.put(
      '/workers/$id',
      body: worker.toUpdateJson(),
    );
    return WorkerModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/workers/$id');
  }
}
