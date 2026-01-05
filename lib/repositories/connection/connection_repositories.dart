import 'base_connection_repositories.dart';

class ConnectionRepository extends BaseConnectionRepository {
  @override
  Future<bool> isConnectedToInternet() async {
    return true;
  }
}
