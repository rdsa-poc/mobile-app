class BootstrapConfig {
  const BootstrapConfig({
    required this.appId,
    required this.baselineMotdMessage,
    required this.databaseNamespace,
    required this.databaseUrl,
    required this.environmentName,
    required this.missingKeys,
    required this.realtimeBaseUrl,
  });

  factory BootstrapConfig.fromEnvironment() {
    const appId = String.fromEnvironment('RADIOSA_APP_ID', defaultValue: 'app');
    const environmentName = String.fromEnvironment('RADIOSA_ENVIRONMENT');
    const sharedRealtimeBaseUrl = String.fromEnvironment('RT_FN_BASE_URL');
    const legacyRealtimeBaseUrl =
        String.fromEnvironment('RADIOSA_REALTIME_BASE_URL');
    const databaseEmulatorHost = String.fromEnvironment(
      'FIREBASE_DATABASE_EMULATOR_HOST',
    );
    const databaseUrlFromEnvironment =
        String.fromEnvironment('FIREBASE_DATABASE_URL');
    const firestoreProjectId = String.fromEnvironment(
      'FIRESTORE_PROJECT_ID',
      defaultValue: 'radiosa-poc',
    );
    const baselineMotdMessage = String.fromEnvironment(
      'RADIOSA_BASELINE_MOTD_MESSAGE',
    );

    final realtimeBaseUrl = sharedRealtimeBaseUrl.isNotEmpty
        ? sharedRealtimeBaseUrl
        : legacyRealtimeBaseUrl;
    final databaseUrl = databaseEmulatorHost.isNotEmpty
        ? 'http://$databaseEmulatorHost'
        : databaseUrlFromEnvironment;
    final databaseNamespace = '$firestoreProjectId-default-rtdb';

    final missingKeys = <String>[
      if (environmentName.isEmpty) 'RADIOSA_ENVIRONMENT',
      if (realtimeBaseUrl.isEmpty) 'RT_FN_BASE_URL',
      if (databaseUrl.isEmpty)
        'FIREBASE_DATABASE_EMULATOR_HOST | FIREBASE_DATABASE_URL',
    ];

    return BootstrapConfig(
      appId: appId,
      baselineMotdMessage: baselineMotdMessage,
      databaseNamespace: databaseNamespace,
      databaseUrl: databaseUrl,
      environmentName: environmentName,
      missingKeys: missingKeys,
      realtimeBaseUrl: realtimeBaseUrl,
    );
  }

  final String appId;
  final String baselineMotdMessage;
  final String databaseNamespace;
  final String databaseUrl;
  final String environmentName;
  final List<String> missingKeys;
  final String realtimeBaseUrl;
}
