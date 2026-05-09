class WebUserStore {
  static final WebUserStore instance = WebUserStore._();
  WebUserStore._();

  Future<List<Map<String, Object?>>> query({String? where, List<Object?> whereArgs = const []}) async => [];
  Future<int> insert(Map<String, Object?> values) async => 0;
  Future<int> update(int id, Map<String, Object?> values) async => 0;
  Future<int> delete(int id) async => 0;
}