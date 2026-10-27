// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gcp_secret_manager/otel_gcp_secret_manager.dart';

/// Traces Secret Manager calls with OpenTelemetry.
///
/// `otel_gcp_secret_manager` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Secret Manager call in
/// [tracedGcpSecretManager]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gcp-secret-manager-example');

  // Wraps a Secret Manager call in a CLIENT span.
  final gcpSecretManagerId = await tracedGcpSecretManager<String>(
    operation: 'secrets.create',
    invoke: () async {
      // Make the Secret Manager call here, then report what it returned.
      const id = 'gcp_secret_manager_8f3a2c';
      return const GcpSecretManagerCallResult(
          value: id,
          result: GcpSecretManagerResult(
              project: 'example',
              secretName: 'projects/<p>/secrets/<s>',
              versionAlias: 'latest',
              versionId: 'version_8f3a2c',
              replicationKind: 'automatic',
              replicationLocations: ['example'],
              cmkKmsKey: 'orders/2026/inv-1042.pdf',
              ttlSec: 1,
              expireUnixSec: 1,
              payloadBytes: 512,
              checksum: 'data_crc32c',
              state: 'ENABLED',
              regional: true,
              rotationPeriodSec: 1,
              nextRotationUnixSec: 1,
              errorCode: 'error.status',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedGcpSecretManager secrets.create returned $gcpSecretManagerId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGcpSecretManagerInstrumentationAsync.
  await runWithoutGcpSecretManagerInstrumentationAsync(
    () => tracedGcpSecretManager<String>(
      operation: 'secrets.create',
      invoke: () async {
        const id = 'gcp_secret_manager_8f3a2c';
        return const GcpSecretManagerCallResult(
            value: id,
            result: GcpSecretManagerResult(
                project: 'example',
                secretName: 'projects/<p>/secrets/<s>',
                versionAlias: 'latest',
                versionId: 'version_8f3a2c',
                replicationKind: 'automatic',
                replicationLocations: ['example'],
                cmkKmsKey: 'orders/2026/inv-1042.pdf',
                ttlSec: 1,
                expireUnixSec: 1,
                payloadBytes: 512,
                checksum: 'data_crc32c',
                state: 'ENABLED',
                regional: true,
                rotationPeriodSec: 1,
                nextRotationUnixSec: 1,
                errorCode: 'error.status',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
