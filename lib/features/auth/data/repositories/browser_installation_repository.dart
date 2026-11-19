import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/metadata_dao.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/device_registration_repository.dart';
import '../../../../shared/models/permission.dart';
import 'native_api_session_repository.dart';

class BrowserInstallationRepository implements DeviceRegistrationRepository {
  BrowserInstallationRepository(this.metadata, this.sessions);
  final MetadataDao metadata;
  final NativeApiSessionRepository sessions;
  String? _terminalId;
  String? get terminalId => _terminalId;
  @override
  Future<String> deviceId() async {
    if (_terminalId case final id?) return id;
    final existing = await metadata.readValue('browser.id');
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await metadata.writeValue(
      key: 'browser.id',
      value: id,
      updatedAt: DateTime.now().toUtc(),
    );
    return id;
  }

  @override
  Future<void> register(AuthSession session) async {
    _terminalId = null;
    if (session.can(AppPermission.processSales) ||
        session.can(AppPermission.manageRegisters)) {
      final response = await sessions.authenticated(
        '/v1/pos/browser-terminal',
        body: {'branchId': session.activeBranchId},
      );
      final id = response['deviceId'] as String;
      await metadata.writeValue(
        key: 'device.id',
        value: id,
        updatedAt: DateTime.now().toUtc(),
      );
      _terminalId = id;
    } else {
      await metadata.deleteValue('device.id');
    }
  }
}
