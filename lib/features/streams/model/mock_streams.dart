import '../../../entities/stream/placeholder_stream.dart';

const mockedStreams = <PlaceholderStream>[
  PlaceholderStream(
    streamId: 'stream-smoke-demo',
    title: 'Smoke Flow Demo Stream',
    status: 'Ready for bootstrap',
    summary:
        'Matches the scaffold smoke-flow bootstrap contract served by bof-be and rt-fn.',
    scheduleLabel: 'Use the documented baseline smoke flow',
    smokeFlowId: 'baseline-smoke-flow',
    quizId: 'quiz-smoke-demo',
    participantId: 'participant-smoke-demo',
  ),
  PlaceholderStream(
    streamId: 'stream-night-quiz',
    title: 'Night Quiz Warmup',
    status: 'Open lobby',
    summary:
        'Static stream entry used to preview the participant join experience.',
    scheduleLabel: 'Lobby available now',
    smokeFlowId: 'night-quiz-placeholder',
    quizId: 'quiz-night-placeholder',
    participantId: 'participant-night-placeholder',
  ),
  PlaceholderStream(
    streamId: 'stream-recap',
    title: 'Results Recap',
    status: 'Archived placeholder',
    summary: 'Shows where replay and recap details will be surfaced later.',
    scheduleLabel: 'Read-only placeholder state',
    smokeFlowId: 'results-recap-placeholder',
    quizId: 'quiz-results-placeholder',
    participantId: 'participant-results-placeholder',
  ),
];

PlaceholderStream? findPlaceholderStreamById(String streamId) {
  for (final stream in mockedStreams) {
    if (stream.streamId == streamId) {
      return stream;
    }
  }

  return null;
}
