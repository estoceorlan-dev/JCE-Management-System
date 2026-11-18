import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jce_pos/core/config/app_config.dart';
import 'package:jce_pos/core/config/app_environment.dart';
import 'package:jce_pos/core/error/failures.dart';
import 'package:jce_pos/core/services/online_availability_service.dart';

void main() {
  final hosted = AppConfig(
    environment: AppEnvironment.staging,
    enableDemoAuth: false,
    enableDiagnostics: false,
    onlineOnly: true,
    apiBaseUri: Uri.parse('https://pos.example.test'),
  );

  test(
    'native offline operation does not depend on a health request',
    () async {
      final client = MockClient((_) => throw StateError('Unexpected request'));
      addTearDown(client.close);
      final service = OnlineAvailabilityService(client);
      const local = AppConfig(
        environment: AppEnvironment.staging,
        enableDemoAuth: false,
        enableDiagnostics: false,
      );

      expect(await service.isReady(local), isTrue);
      await service.ensureReady(local);
      expect(await service.mutationPrecondition(local), isNull);
    },
  );

  test(
    'hosted readiness uses the configured origin and readiness path',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, Uri.parse('https://pos.example.test/health/ready'));
        return http.Response('{"status":"ok","database":"connected"}', 200);
      });
      addTearDown(client.close);
      final service = OnlineAvailabilityService(client);

      expect(await service.isReady(hosted), isTrue);
      expect(await service.mutationPrecondition(hosted), isNull);
    },
  );

  test('unready hosted service rejects startup and new mutations', () async {
    final client = MockClient((_) async => http.Response('', 503));
    addTearDown(client.close);
    final service = OnlineAvailabilityService(client);

    expect(await service.isReady(hosted), isFalse);
    await expectLater(
      service.ensureReady(hosted),
      throwsA(
        isA<NetworkFailure>().having((f) => f.code, 'code', 'online_required'),
      ),
    );
    expect(
      await service.mutationPrecondition(hosted),
      isA<NetworkFailure>().having((f) => f.code, 'code', 'online_required'),
    );
  });

  test(
    'a successful HTML fallback or liveness response cannot enable writes',
    () async {
      for (final body in [
        '<html></html>',
        '{"status":"ok"}',
        '{"status":"ok","database":"unavailable"}',
      ]) {
        final client = MockClient((_) async => http.Response(body, 200));
        addTearDown(client.close);
        expect(
          await OnlineAvailabilityService(client).mutationPrecondition(hosted),
          isA<NetworkFailure>(),
        );
      }
    },
  );

  test('network failure can recover without recreating the service', () async {
    var online = false;
    final client = MockClient((_) async {
      if (!online) throw http.ClientException('API unreachable');
      return http.Response('{"status":"ok","database":"connected"}', 200);
    });
    addTearDown(client.close);
    final service = OnlineAvailabilityService(client);

    expect(await service.isReady(hosted), isFalse);
    online = true;
    expect(await service.isReady(hosted), isTrue);
  });

  test('missing hosted origin rejects without sending a request', () async {
    final client = MockClient((_) => throw StateError('Unexpected request'));
    addTearDown(client.close);
    final service = OnlineAvailabilityService(client);
    const invalid = AppConfig(
      environment: AppEnvironment.staging,
      enableDemoAuth: false,
      enableDiagnostics: false,
      onlineOnly: true,
    );

    expect(await service.isReady(invalid), isFalse);
  });
}
