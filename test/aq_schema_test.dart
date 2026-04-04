import 'package:aq_schema/aq_schema.dart';
import 'package:test/test.dart';

void main() {
  group('aq_schema', () {
    group('McpError', () {
      test('creates with code and message', () {
        const err = McpError(code: -32600, message: 'Invalid Request');
        expect(err.code, -32600);
        expect(err.message, 'Invalid Request');
      });

      test('fromJson round-trip', () {
        final json = {
          'code': -32000,
          'message': 'Worker failed',
          'data': 'detail',
        };
        final err = McpError.fromJson(json);
        expect(err.code, -32000);
        expect(err.data, 'detail');
        expect(err.toJson()['data'], 'detail');
      });

      test('convenience constructors produce correct codes', () {
        expect(McpError.parseError().code, McpErrorCode.parseError);
        expect(McpError.invalidRequest().code, McpErrorCode.invalidRequest);
        expect(
          McpError.methodNotFound('foo').code,
          McpErrorCode.methodNotFound,
        );
        expect(McpError.invalidParams().code, McpErrorCode.invalidParams);
        expect(
          McpError.workerTimeout('job-1').code,
          McpErrorCode.workerTimeout,
        );
        expect(
          McpError.workerNotAvailable('search').code,
          McpErrorCode.workerNotAvailable,
        );
        expect(McpError.authRequired().code, McpErrorCode.authRequired);
        expect(McpError.authInvalid().code, McpErrorCode.authInvalid);
      });
    });

    group('McpToolImpl', () {
      final validToolJson = {
        'name': 'search_web',
        'description': 'Searches the web for information',
        'inputSchema': {
          'type': 'object',
          'required': ['query'],
          'properties': {
            'query': {'type': 'string'},
          },
        },
      };

      test('fromJson parses correctly', () {
        final tool = McpToolImpl.fromJson(validToolJson);
        expect(tool.name, 'search_web');
        expect(tool.description, 'Searches the web for information');
        expect(tool.auth, isNull);
      });

      test('toJson round-trip', () {
        final tool = McpToolImpl.fromJson(validToolJson);
        final json = tool.toJson();
        expect(json['name'], 'search_web');
        expect(json.containsKey('_aq_auth'), isFalse);
      });

      test('fromJson with auth extension', () {
        final json = {
          ...validToolJson,
          '_aq_auth': {'required': true, 'type': 'bearer'},
        };
        final tool = McpToolImpl.fromJson(json);
        expect(tool.auth, isNotNull);
        expect(tool.auth!.required, isTrue);
        expect(tool.auth!.type, AuthType.bearer);
      });

      test('equality by name', () {
        final a = McpToolImpl.fromJson(validToolJson);
        final b = McpToolImpl.fromJson(validToolJson);
        expect(a, equals(b));
      });
    });

    group('McpRequest.fromJson', () {
      test('parses initialize', () {
        final json = {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
          'params': {
            'protocolVersion': '2024-11-05',
            'clientInfo': {'name': 'test', 'version': '1.0'},
          },
        };
        final req = McpRequest.fromJson(json);
        expect(req, isA<McpInitializeRequest>());
        final init = req as McpInitializeRequest;
        expect(init.protocolVersion, '2024-11-05');
        expect(init.clientInfo?.name, 'test');
      });

      test('parses tools/list', () {
        final json = {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'};
        expect(McpRequest.fromJson(json), isA<McpToolsListRequest>());
      });

      test('parses tools/call with aq extensions', () {
        final json = {
          'jsonrpc': '2.0',
          'id': 3,
          'method': 'tools/call',
          'params': {
            'name': 'search_web',
            'arguments': {'query': 'dart mcp'},
            '_aq_mode': 'async',
          },
        };
        final req = McpRequest.fromJson(json) as McpToolsCallRequest;
        expect(req.name, 'search_web');
        expect(req.arguments['query'], 'dart mcp');
        expect(req.mode, ExecutionMode.async);
      });

      test('returns McpUnknownRequest for unknown methods', () {
        final json = {
          'jsonrpc': '2.0',
          'id': 99,
          'method': 'notifications/initialized',
        };
        expect(McpRequest.fromJson(json), isA<McpUnknownRequest>());
      });
    });

    group('McpSuccessResponse / McpErrorResponse', () {
      test('success toJson includes jsonrpc 2.0', () {
        final res = McpSuccessResponse(id: 1, result: {'tools': []});
        final json = res.toJson();
        expect(json['jsonrpc'], '2.0');
        expect(json['result'], {'tools': []});
      });

      test('error toJson includes error object', () {
        final res = McpErrorResponse(
          id: 1,
          error: McpError.invalidParams('bad arg'),
        );
        final json = res.toJson();
        expect(json['error']['code'], McpErrorCode.invalidParams);
      });
    });

    group('McpCapabilities', () {
      test('fromJson with aq_extensions', () {
        final json = {
          'tools': {'listChanged': true},
          '_aq_extensions': {
            'auth': {
              'supported': true,
              'methods': ['bearer'],
            },
            'async_jobs': true,
            'worker_count': 3,
          },
        };
        final caps = McpCapabilities.fromJson(json);
        expect(caps.tools.listChanged, isTrue);
        expect(caps.aqExtensions?.authSupported, isTrue);
        expect(caps.aqExtensions?.asyncJobs, isTrue);
        expect(caps.aqExtensions?.workerCount, 3);
      });

      test('toJson omits _aq_extensions when null', () {
        const caps = McpCapabilities();
        final json = caps.toJson();
        expect(json.containsKey('_aq_extensions'), isFalse);
      });
    });

    // ── Auth ────────────────────────────────────────────────

    group('AuthContext', () {
      test('mockContext is valid', () {
        final ctx = AuthContext.mockContext();
        expect(ctx.validated, isTrue);
        expect(ctx.isMock, isTrue);
        expect(ctx.scopes, contains('*'));
      });

      test('anonymous context', () {
        final ctx = AuthContext.anonymous();
        expect(ctx.type, AuthType.none);
        expect(ctx.validated, isTrue);
        expect(ctx.isMock, isFalse);
      });

      test('fromJson round-trip', () {
        final ctx = AuthContext.mockContext();
        final json = ctx.toJson();
        final ctx2 = AuthContext.fromJson(json);
        expect(ctx2.subject, ctx.subject);
        expect(ctx2.isMock, ctx.isMock);
      });

      test('isExpired returns false when no expiresAt', () {
        final ctx = AuthContext.anonymous();
        expect(ctx.isExpired, isFalse);
      });

      test('isExpired returns true for past timestamp', () {
        final ctx = AuthContext(
          type: AuthType.bearer,
          validated: true,
          timestamp: 0,
          expiresAt: 1, // very old
        );
        expect(ctx.isExpired, isTrue);
      });
    });

    group('AuthResult', () {
      test('mock result is success', () {
        final result = AuthResult.mock();
        expect(result.success, isTrue);
        expect(result.context?.isMock, isTrue);
      });

      test('failure result carries reason', () {
        final result = AuthResult.failure(AuthFailureReason.tokenExpired);
        expect(result.success, isFalse);
        expect(result.failureReason, AuthFailureReason.tokenExpired);
      });

      test('fromJson round-trip', () {
        final result = AuthResult.mock();
        final json = result.toJson();
        final result2 = AuthResult.fromJson(json);
        expect(result2.success, isTrue);
      });
    });

    group('AuthTokenPayload', () {
      test('empty payload serializes', () {
        final payload = AuthTokenPayload.empty;
        expect(payload.type, AuthType.none);
        expect(payload.toJson()['type'], 'none');
      });

      test('fromJson bearer', () {
        final json = {'type': 'bearer', 'token': 'abc123'};
        final payload = AuthTokenPayload.fromJson(json);
        expect(payload.type, AuthType.bearer);
        expect(payload.token, 'abc123');
      });
    });

    // ── Worker ──────────────────────────────────────────────

    group('WorkerRegistration', () {
      final validJson = {
        'worker_id': 'search-worker',
        'tools': [
          {
            'name': 'search_web',
            'description': 'Web search tool',
            'inputSchema': {'type': 'object'},
          },
        ],
        'capabilities': {'async': true, 'concurrency': 4},
      };

      test('fromJson parses correctly', () {
        final reg = WorkerRegistration.fromJson(validJson);
        expect(reg.workerId, 'search-worker');
        expect(reg.tools.length, 1);
        expect(reg.tools.first.name, 'search_web');
        expect(reg.capabilities.concurrency, 4);
      });

      test('toJson round-trip', () {
        final reg = WorkerRegistration.fromJson(validJson);
        final json = reg.toJson();
        expect(json['worker_id'], 'search-worker');
      });
    });

    group('WorkerJobImpl', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final validJson = {
        'job_id': 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        'tool': 'search_web',
        'payload': {'query': 'dart'},
        'created_at': now,
        'meta': {'timeout_ms': 5000, 'mode': 'sync'},
      };

      test('fromJson parses correctly', () {
        final job = WorkerJobImpl.fromJson(validJson);
        expect(job.jobId, 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee');
        expect(job.tool, 'search_web');
        expect(job.payload['query'], 'dart');
        expect(job.meta?.timeoutMs, 5000);
        expect(job.meta?.timeout, const Duration(seconds: 5));
      });

      test('toJson round-trip', () {
        final job = WorkerJobImpl.fromJson(validJson);
        final json = job.toJson();
        final job2 = WorkerJobImpl.fromJson(json);
        expect(job2.jobId, job.jobId);
      });
    });

    group('WorkerResultImpl', () {
      test('success factory', () {
        final result = WorkerResultImpl.success(
          jobId: 'job-1',
          result: {'data': 'hello'},
          durationMs: 42,
        );
        expect(result.status, JobStatus.done);
        expect(result.status.isTerminal, isTrue);
        expect(result.result?['data'], 'hello');
        expect(result.durationMs, 42);
      });

      test('failure factory', () {
        final result = WorkerResultImpl.failure(
          jobId: 'job-2',
          error: WorkerError.executionFailed('boom'),
        );
        expect(result.status, JobStatus.failed);
        expect(result.error?.type, WorkerErrorType.executionError);
      });

      test('timedOut factory', () {
        final result = WorkerResultImpl.timedOut('job-3');
        expect(result.status, JobStatus.timeout);
        expect(result.error?.type, WorkerErrorType.timeout);
      });

      test('fromJson round-trip', () {
        final result = WorkerResultImpl.success(
          jobId: 'job-4',
          result: {'answer': 42},
        );
        final json = result.toJson();
        final result2 = WorkerResultImpl.fromJson(json);
        expect(result2.jobId, result.jobId);
        expect(result2.status, JobStatus.done);
      });
    });

    group('WorkerHealth', () {
      test('fromJson parses correctly', () {
        final json = {
          'worker_id': 'my-worker',
          'status': 'healthy',
          'timestamp': 1000,
          'active_jobs': 2,
        };
        final health = WorkerHealth.fromJson(json);
        expect(health.status, WorkerStatus.healthy);
        expect(health.activeJobs, 2);
      });
    });

    group('QueueJobStatus', () {
      test('fromJson pending status', () {
        final json = {'job_id': 'abc', 'status': 'pending', 'created_at': 1000};
        final status = QueueJobStatus.fromJson(json);
        expect(status.status, JobStatus.pending);
        expect(status.status.isTerminal, isFalse);
      });
    });

    // ── Validators ──────────────────────────────────────────

    group('McpValidator', () {
      test('validateJsonRpc passes valid message', () {
        final result = McpValidator.validateJsonRpc({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
        });
        expect(result.isValid, isTrue);
      });

      test('validateJsonRpc fails wrong version', () {
        final result = McpValidator.validateJsonRpc({
          'jsonrpc': '1.0',
          'id': 1,
          'method': 'foo',
        });
        expect(result.isValid, isFalse);
        expect(result.errors.first, contains('jsonrpc'));
      });

      test('validateTool passes valid tool', () {
        final result = McpValidator.validateTool({
          'name': 'my_tool',
          'description': 'Does something',
          'inputSchema': {'type': 'object'},
        });
        expect(result.isValid, isTrue);
      });

      test('validateTool fails invalid name (CamelCase)', () {
        final result = McpValidator.validateTool({
          'name': 'MyTool',
          'description': 'x',
          'inputSchema': {'type': 'object'},
        });
        expect(result.isValid, isFalse);
        expect(result.errors.first, contains('snake_case'));
      });

      test('validateTool fails empty description', () {
        final result = McpValidator.validateTool({
          'name': 'ok_name',
          'description': '',
          'inputSchema': {'type': 'object'},
        });
        expect(result.isValid, isFalse);
      });

      test('validateToolArguments passes when all required present', () {
        final result = McpValidator.validateToolArguments(
          inputSchema: {
            'type': 'object',
            'required': ['query'],
          },
          arguments: {'query': 'hello'},
          toolName: 'search',
        );
        expect(result.isValid, isTrue);
      });

      test('validateToolArguments fails when required field missing', () {
        final result = McpValidator.validateToolArguments(
          inputSchema: {
            'type': 'object',
            'required': ['query', 'limit'],
          },
          arguments: {'query': 'hello'},
          toolName: 'search',
        );
        expect(result.isValid, isFalse);
        expect(result.errors.first, contains('limit'));
      });

      test('isKnownErrorCode returns true for standard codes', () {
        expect(McpValidator.isKnownErrorCode(-32700), isTrue);
        expect(McpValidator.isKnownErrorCode(-32000), isTrue);
        expect(McpValidator.isKnownErrorCode(-32004), isTrue);
      });

      test('isKnownErrorCode returns false for unknown codes', () {
        expect(McpValidator.isKnownErrorCode(-99999), isFalse);
        expect(McpValidator.isKnownErrorCode(0), isFalse);
      });
    });

    group('WorkerValidator', () {
      final validReg = {
        'worker_id': 'my-worker',
        'tools': [
          {
            'name': 'echo',
            'description': 'Echoes input',
            'inputSchema': {'type': 'object'},
          },
        ],
        'capabilities': {'async': false, 'concurrency': 2},
      };

      test('validateRegistration passes valid registration', () {
        final result = WorkerValidator.validateRegistration(validReg);
        expect(result.isValid, isTrue);
      });

      test('validateRegistration fails empty worker_id', () {
        final json = {...validReg, 'worker_id': ''};
        expect(WorkerValidator.validateRegistration(json).isValid, isFalse);
      });

      test('validateRegistration fails invalid worker_id pattern', () {
        final json = {...validReg, 'worker_id': 'My_Worker'};
        final result = WorkerValidator.validateRegistration(json);
        expect(result.isValid, isFalse);
        expect(result.errors.first, contains('kebab-case'));
      });

      test('validateRegistration fails empty tools list', () {
        final json = {...validReg, 'tools': <dynamic>[]};
        expect(WorkerValidator.validateRegistration(json).isValid, isFalse);
      });

      test('validateRegistration fails concurrency 0', () {
        final json = {
          ...validReg,
          'capabilities': {'async': false, 'concurrency': 0},
        };
        expect(WorkerValidator.validateRegistration(json).isValid, isFalse);
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final validJob = {
        'job_id': 'aaaaaaaa-0000-0000-0000-000000000000',
        'tool': 'echo',
        'payload': {},
        'created_at': now,
      };

      test('validateJob passes valid job', () {
        expect(WorkerValidator.validateJob(validJob).isValid, isTrue);
      });

      test('validateJob fails invalid tool name', () {
        final json = {...validJob, 'tool': 'Echo'};
        expect(WorkerValidator.validateJob(json).isValid, isFalse);
      });

      test('validateResult fails done without result', () {
        final json = {
          'job_id': 'abc',
          'status': 'done',
          'completed_at': now,
          // missing result
        };
        expect(WorkerValidator.validateResult(json).isValid, isFalse);
      });

      test('validateResult fails failed without error', () {
        final json = {
          'job_id': 'abc',
          'status': 'failed',
          'completed_at': now,
          // missing error
        };
        expect(WorkerValidator.validateResult(json).isValid, isFalse);
      });

      test('validateResult passes valid done result', () {
        final json = {
          'job_id': 'abc',
          'status': 'done',
          'completed_at': now,
          'result': {'data': 'ok'},
        };
        expect(WorkerValidator.validateResult(json).isValid, isTrue);
      });

      test('validateHealth passes valid health', () {
        final json = {'worker_id': 'w1', 'status': 'healthy', 'timestamp': now};
        expect(WorkerValidator.validateHealth(json).isValid, isTrue);
      });

      test('validateHealth fails bad status', () {
        final json = {'worker_id': 'w1', 'status': 'great', 'timestamp': now};
        expect(WorkerValidator.validateHealth(json).isValid, isFalse);
      });
    });
  });
}
