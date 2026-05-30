import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Domain-level error type. Every repository and use case returns
/// `Either<Failure, T>` (fpdart) — presentation pattern-matches on these
/// variants and never touches raw exceptions.
///
/// [i18nKey] points at a key in `assets/translations/*.json` so the UI can
/// localize the message without leaking technical detail.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.server({
    @Default('error.server') String i18nKey,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    @Default('error.network') String i18nKey,
  }) = NetworkFailure;

  const factory Failure.auth({
    @Default('error.auth') String i18nKey,
  }) = AuthFailure;

  const factory Failure.rateLimit({
    @Default('error.rateLimit') String i18nKey,
  }) = RateLimitFailure;

  const factory Failure.cache({
    @Default('error.cache') String i18nKey,
  }) = CacheFailure;

  const factory Failure.location({
    @Default('error.location') String i18nKey,
  }) = LocationFailure;

  const factory Failure.unknown({
    @Default('error.unknown') String i18nKey,
  }) = UnknownFailure;

  /// True when the failure is a candidate for falling back to mock data
  /// (auth / rate-limit problems with the remote OpenSky source).
  bool get isFallbackCandidate =>
      this is AuthFailure || this is RateLimitFailure;
}
