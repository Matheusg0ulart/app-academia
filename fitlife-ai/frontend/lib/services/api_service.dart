import '../core/constants/app_constants.dart';

/// Classe de serviço reservada para futuras requisições HTTP
/// conectando o aplicativo Flutter à API REST em Node.js.
class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConstants.apiBaseUrl});

  /// Exemplo de chamada para verificar o status do backend
  Future<bool> checkHealth() async {
    // TODO: Implementar chamada HTTP na próxima etapa
    return true;
  }
}
