abstract class SyncRemote {
  Future<void> pushProduct(Map<String, dynamic> payload);
  Future<void> pushTransaction(Map<String, dynamic> payload);
  Future<void> pushParseLog(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> pullProducts(
      String storeId, DateTime since);
  Future<List<Map<String, dynamic>>> pullTransactions(
      String storeId, DateTime since);
}
