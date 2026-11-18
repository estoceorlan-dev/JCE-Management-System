import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jce_pos/core/config/app_config.dart';
import 'package:jce_pos/core/config/app_environment.dart';
import 'package:jce_pos/core/services/online_availability_service.dart';
import 'package:jce_pos/core/widgets/online_required_gate.dart';

void main() {
  testWidgets('hosted outage blocks interaction and retry restores it', (
    tester,
  ) async {
    var online = false;
    var actions = 0;
    final client = MockClient(
      (_) async => http.Response(
        '{"status":"ok","database":"connected"}',
        online ? 200 : 503,
      ),
    );
    addTearDown(client.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              environment: AppEnvironment.staging,
              enableDemoAuth: false,
              enableDiagnostics: false,
              onlineOnly: true,
              apiBaseUri: Uri.parse('https://pos.example.test'),
            ),
          ),
          onlineAvailabilityServiceProvider.overrideWithValue(
            OnlineAvailabilityService(client),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: OnlineRequiredGate(
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => actions++,
                  child: const Text('Save change'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();

    expect(find.text('Online connection required'), findsOneWidget);
    await tester.tap(find.text('Save change'), warnIfMissed: false);
    expect(actions, 0);

    online = true;
    await tester.tap(find.text('Retry connection'));
    await tester.pumpAndSettle();
    expect(find.text('Online connection required'), findsNothing);
    await tester.tap(find.text('Save change'));
    expect(actions, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('native profile stays usable without readiness probes', (
    tester,
  ) async {
    final client = MockClient((_) => throw StateError('Unexpected request'));
    addTearDown(client.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              environment: AppEnvironment.staging,
              enableDemoAuth: false,
              enableDiagnostics: false,
            ),
          ),
          onlineAvailabilityServiceProvider.overrideWithValue(
            OnlineAvailabilityService(client),
          ),
        ],
        child: const MaterialApp(
          home: OnlineRequiredGate(child: Text('Local workspace')),
        ),
      ),
    );
    await tester.pump(const Duration(minutes: 1));

    expect(find.text('Local workspace'), findsOneWidget);
    expect(find.text('Online connection required'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
