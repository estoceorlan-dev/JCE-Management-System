import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../auth/data/repositories/native_api_session_repository.dart';
import '../../../auth/data/repositories/browser_api_session_repository.dart';
import '../../domain/entities/register_claim_action_grant.dart';
import '../../domain/repositories/register_claim_authorization_service.dart';

class NodeRegisterClaimAuthorizationService
    implements RegisterClaimAuthorizationService {
  const NodeRegisterClaimAuthorizationService(this.sessions);
  final NativeApiSessionRepository sessions;
  @override
  Future<Result<RegisterClaimActionGrant, Failure>> authorize({
    required String managerEmail,
    required String managerPassword,
    required String organizationId,
    required String branchId,
    required String conflictId,
    required String targetRegisterId,
    required String deviceId,
    required String requestedByUserId,
    required String nonce,
  }) async {
    String? access;
    final api = sessions.api;
    try {
      const path = '/v1/register-claims/authorizations';
      final manager = {
        'organizationCode': api.profile.organizationCode,
        'email': managerEmail,
        'password': managerPassword,
      };
      final grant = {
        'branchId': branchId,
        'conflictId': conflictId,
        'targetRegisterId': targetRegisterId,
        'deviceId': deviceId,
        'requestedByUserId': requestedByUserId,
        'nonce': nonce,
      };
      final Map<String, dynamic> value;
      if (sessions is BrowserApiSessionRepository) {
        value = await sessions.authenticated(
          path,
          body: {...grant, 'manager': manager},
        );
      } else {
        final login = await api.request(
          '/v1/auth/login',
          body: {...manager, 'clientType': 'native'},
        );
        access = login['accessToken'] as String;
        value = await api.request(path, accessToken: access, body: grant);
      }
      return Result.success(
        RegisterClaimActionGrant(
          id: value['grantId'] as String,
          nonce: nonce,
          managerUserId: value['managerUserId'] as String,
          expiresAt: DateTime.parse(value['expiresAt'] as String).toUtc(),
        ),
      );
    } catch (error, stack) {
      return Result.failure(FailureMapper.fromException(error, stack));
    } finally {
      if (access != null) {
        try {
          await api.request('/v1/auth/logout', accessToken: access);
        } catch (_) {
          /* Short-lived session expires server-side. */
        }
      }
    }
  }
}
