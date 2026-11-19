import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/node_account_action_service.dart';
import '../../domain/services/account_action_service.dart';
import '../providers/native_auth_providers.dart';

final staffCredentialsProvider = Provider<NodeAccountActionService>(
  (ref) =>
      NodeAccountActionService(ref.watch(nativeApiSessionRepositoryProvider)),
);

final accountActionServiceProvider = Provider<AccountActionService>(
  (ref) =>
      NodeAccountActionService(ref.watch(nativeApiSessionRepositoryProvider)),
);
