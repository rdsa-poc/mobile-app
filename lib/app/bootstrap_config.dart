class BootstrapConfig {
  const BootstrapConfig({
    required this.appId,
    required this.baselineMotdMessage,
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
    const baselineMotdMessage = String.fromEnvironment(
      'RADIOSA_BASELINE_MOTD_MESSAGE',
    );

    final realtimeBaseUrl = sharedRealtimeBaseUrl.isNotEmpty
        ? sharedRealtimeBaseUrl
        : legacyRealtimeBaseUrl;

    final missingKeys = <String>[
      if (environmentName.isEmpty) 'RADIOSA_ENVIRONMENT',
      if (realtimeBaseUrl.isEmpty) 'RT_FN_BASE_URL',
    ];

    return BootstrapConfig(
      appId: appId,
      baselineMotdMessage: baselineMotdMessage,
      environmentName: environmentName,
      missingKeys: missingKeys,
      realtimeBaseUrl: realtimeBaseUrl,
    );
  }

  final String appId;
  final String baselineMotdMessage;
  final String environmentName;
  final List<String> missingKeys;
  final String realtimeBaseUrl;
}
