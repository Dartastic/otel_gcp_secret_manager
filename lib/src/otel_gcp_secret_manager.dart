// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_gcp_secret_manager_suppression.dart';

const _tracerName = 'dartastic_otel_libs_gcp_secret_manager';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class GcpSecretManagerResult {
  const GcpSecretManagerResult({
    this.project,
    this.secretName,
    this.versionAlias,
    this.versionId,
    this.replicationKind,
    this.replicationLocations,
    this.cmkKmsKey,
    this.ttlSec,
    this.expireUnixSec,
    this.payloadBytes,
    this.checksum,
    this.state,
    this.regional,
    this.rotationPeriodSec,
    this.nextRotationUnixSec,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  final String? project;

  /// Secret resource name (`projects/<p>/secrets/<s>`).
  final String? secretName;

  /// `latest` or numeric (`1`, `42`).
  final String? versionAlias;

  /// Numeric version id resolved by the server.
  final String? versionId;

  /// `automatic`, `user_managed`.
  final String? replicationKind;
  final List<String>? replicationLocations;

  /// CMEK KMS key name.
  final String? cmkKmsKey;

  /// `ttl` field in seconds.
  final int? ttlSec;

  /// `expireTime` as unix seconds.
  final int? expireUnixSec;

  final int? payloadBytes;

  /// `data_crc32c`.
  final String? checksum;

  /// `ENABLED`, `DISABLED`, `DESTROYED`.
  final String? state;

  /// Regional Secret Manager (locational endpoint).
  final bool? regional;

  final int? rotationPeriodSec;
  final int? nextRotationUnixSec;

  /// Google `error.status` (`OK`, `NOT_FOUND`, `PERMISSION_DENIED`,
  /// `UNAUTHENTICATED`, `RESOURCE_EXHAUSTED`, `ABORTED`, `INTERNAL`,
  /// `FAILED_PRECONDITION`, `ALREADY_EXISTS`).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class GcpSecretManagerCallResult<T> {
  const GcpSecretManagerCallResult({required this.value, this.result});
  final T value;
  final GcpSecretManagerResult? result;
}

/// Wraps a Secret Manager call in a CLIENT span. [operation] is one of
/// `secrets.create`, `secrets.update`, `secrets.delete`, `secrets.get`,
/// `secrets.list`, `secrets.iam.set`, `secrets.iam.get`,
/// `versions.access`, `versions.get`, `versions.list`, `versions.enable`,
/// `versions.disable`, `versions.destroy`, `versions.addVersion`.
Future<T> tracedGcpSecretManager<T>({
  required String operation,
  required Future<GcpSecretManagerCallResult<T>> Function() invoke,
}) async {
  if (gcpSecretManagerInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'gcp_secret_manager',
    'rpc.method': operation,
    'gcp_secret_manager.operation': operation,
  };

  final span = _tracer().startSpan(
    'gcp_secret_manager $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.project != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.project',
          res.project!,
        ));
      }
      if (res.secretName != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.secret.name',
          res.secretName!,
        ));
      }
      if (res.versionAlias != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.version.alias',
          res.versionAlias!,
        ));
      }
      if (res.versionId != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.version.id',
          res.versionId!,
        ));
      }
      if (res.replicationKind != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.replication.kind',
          res.replicationKind!,
        ));
      }
      if (res.replicationLocations != null) {
        extras.add(OTel.attributeStringList(
          'gcp_secret_manager.replication.locations',
          res.replicationLocations!,
        ));
      }
      if (res.cmkKmsKey != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.cmk.key_name',
          res.cmkKmsKey!,
        ));
      }
      if (res.ttlSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_secret_manager.ttl_sec',
          res.ttlSec!,
        ));
      }
      if (res.expireUnixSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_secret_manager.expire_at_sec',
          res.expireUnixSec!,
        ));
      }
      if (res.payloadBytes != null) {
        extras.add(OTel.attributeInt(
          'gcp_secret_manager.payload.bytes',
          res.payloadBytes!,
        ));
      }
      if (res.checksum != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.checksum',
          res.checksum!,
        ));
      }
      if (res.state != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.version.state',
          res.state!,
        ));
      }
      if (res.regional != null) {
        extras.add(OTel.attributeBool(
          'gcp_secret_manager.regional',
          res.regional!,
        ));
      }
      if (res.rotationPeriodSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_secret_manager.rotation.period_sec',
          res.rotationPeriodSec!,
        ));
      }
      if (res.nextRotationUnixSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_secret_manager.rotation.next_at_sec',
          res.nextRotationUnixSec!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.error.code',
          res.errorCode!,
        ));
        if (res.errorCode != 'OK') {
          span.setStatus(
            SpanStatusCode.Error,
            'Secret Manager ${res.errorCode}',
          );
        }
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'gcp_secret_manager.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Secret Manager HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
