// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_gcp_secret_manager/otel_gcp_secret_manager.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_gcp_secret_manager-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('versions.access records version + payload size + state', () async {
    await tracedGcpSecretManager<String>(
      operation: 'versions.access',
      invoke: () async => const GcpSecretManagerCallResult(
        value: 'ok',
        result: GcpSecretManagerResult(
          project: 'p1',
          secretName: 'projects/p1/secrets/db-pass',
          versionAlias: 'latest',
          versionId: '7',
          payloadBytes: 32,
          state: 'ENABLED',
          checksum: '1234',
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('gcp_secret_manager versions.access')!,
    );
    expect(a['gcp_secret_manager.version.id'], '7');
    expect(a['gcp_secret_manager.payload.bytes'], 32);
    expect(a['gcp_secret_manager.version.state'], 'ENABLED');
  });

  test('NOT_FOUND sets span error', () async {
    await tracedGcpSecretManager<String>(
      operation: 'secrets.get',
      invoke: () async => const GcpSecretManagerCallResult(
        value: 'ok',
        result: GcpSecretManagerResult(
          errorCode: 'NOT_FOUND',
          statusCode: 404,
        ),
      ),
    );
    expect(
      spans.findSpanByName('gcp_secret_manager secrets.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('OK is non-error', () async {
    await tracedGcpSecretManager<String>(
      operation: 'secrets.get',
      invoke: () async => const GcpSecretManagerCallResult(
        value: 'ok',
        result: GcpSecretManagerResult(errorCode: 'OK'),
      ),
    );
    expect(
      spans.findSpanByName('gcp_secret_manager secrets.get')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutGcpSecretManagerInstrumentationAsync(() async {
      await tracedGcpSecretManager<String>(
        operation: 'secrets.list',
        invoke: () async => const GcpSecretManagerCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('gcp_secret_manager '), isEmpty);
  });
}
