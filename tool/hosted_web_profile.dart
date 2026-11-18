import 'dart:convert';
import 'dart:io';

import 'package:jce_pos/core/config/release_config_validator.dart';

void main(List<String> arguments) {
  final env = Platform.environment;
  final profile = {
    'JCE_ENV': 'production',
    'JCE_BACKEND': 'node',
    'JCE_ENABLE_DEMO_AUTH': 'false',
    'JCE_ENABLE_DIAGNOSTICS': 'false',
    'JCE_ONLINE_ONLY': 'true',
    'JCE_ALLOW_HTTP_LOOPBACK': 'false',
    'JCE_API_BASE_URL': env['JCE_PUBLIC_ORIGIN'],
    'JCE_DEPLOYMENT_ID': env['JCE_DEPLOYMENT_ID'],
    'JCE_ORGANIZATION_CODE': env['JCE_ORGANIZATION_CODE'],
    'JCE_OFFLINE_VERIFICATION_KEYS': env['JCE_OFFLINE_VERIFICATION_KEYS'],
  };
  final errors = ReleaseConfigValidator.validate(
    values: profile,
    platform: ReleasePlatform.web,
    expectedDeploymentId: env['JCE_APPROVED_PRODUCTION_DEPLOYMENT_ID'] ?? '',
  );
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 64;
    return;
  }
  File(arguments.single).writeAsStringSync(jsonEncode(profile));
}
