import 'dart:convert';

import 'package:fluent_cms_api/src/registry/sdui_module.dart';

/// Generates a JSON Schema (Draft 2020-12) describing the `fluent_cms`
/// Master Schema v1.0.
class CmsJsonSchemaGenerator {
  /// Creates a [CmsJsonSchemaGenerator].
  const CmsJsonSchemaGenerator();

  /// Official JSON Schema Draft 2020-12 URI.
  static const String draft202012Uri =
      'https://json-schema.org/draft/2020-12/schema';

  /// Default canonical URL pointing to the raw schema file on GitHub main
  /// branch.
  static const String defaultSchemaId =
      'https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/'
      'packages/fluent_cms/fluent_cms/schema/cms_schema.json';

  /// Generates a JSON Schema map (`cms_schema.json`), optionally enriched with
  /// [modules] registered in the application.
  static Map<String, dynamic> generate({
    Iterable<SduiModule> modules = const <SduiModule>[],
    String schemaId = defaultSchemaId,
  }) {
    final moduleTypes = <String>['cms_repeater'];
    final modulePropsDefs = <String, Map<String, dynamic>>{};

    for (final module in modules) {
      var exists = false;
      for (var i = 0; i < moduleTypes.length; i++) {
        if (moduleTypes[i] == module.type) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        moduleTypes.add(module.type);
      }
      if (module.propsSchema.isNotEmpty) {
        modulePropsDefs[module.type] = module.propsSchema;
      }
    }

    final moduleNodeProperties = <String, dynamic>{
      'id': <String, dynamic>{
        'type': 'string',
        'minLength': 1,
        'description': 'Unique instance identifier on the page.',
      },
      'type': <String, dynamic>{
        'type': 'string',
        'minLength': 1,
        if (modules.isNotEmpty) 'enum': moduleTypes,
        'description': 'Registered SDUI module key.',
      },
      'platforms': <String, dynamic>{
        'type': 'array',
        'items': <String, dynamic>{
          'type': 'string',
          'enum': <String>[
            'android',
            'ios',
            'web',
            'desktop',
            'macos',
            'windows',
            'linux',
          ],
        },
      },
      'visibleWhen': <String, dynamic>{'type': 'string'},
      'requiresData': <String, dynamic>{
        'type': 'array',
        'items': <String, dynamic>{'type': 'string'},
      },
      'hideOnError': <String, dynamic>{'type': 'boolean', 'default': true},
      'keepAlive': <String, dynamic>{'type': 'boolean', 'default': false},
      'a11y': <String, dynamic>{r'$ref': r'#/$defs/A11yConfig'},
      'props': <String, dynamic>{
        'type': 'object',
        'additionalProperties': true,
      },
      'responsiveProps': <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'mobile': <String, dynamic>{'type': 'object'},
          'tablet': <String, dynamic>{'type': 'object'},
          'desktop': <String, dynamic>{'type': 'object'},
        },
        'additionalProperties': false,
      },
      'actions': <String, dynamic>{
        'type': 'object',
        'additionalProperties': <String, dynamic>{
          r'$ref': r'#/$defs/ActionNode',
        },
      },
    };

    return <String, dynamic>{
      r'$schema': draft202012Uri,
      r'$id': schemaId,
      'title': 'Fluent CMS Master Schema v1.0',
      'type': 'object',
      'required': <String>['schemaVersion', 'pageId', 'layout', 'zones'],
      'properties': <String, dynamic>{
        'schemaVersion': <String, dynamic>{
          'type': 'string',
          'default': '1.0.0',
        },
        'pageId': <String, dynamic>{
          'type': 'string',
          'minLength': 1,
        },
        'cacheTtlSeconds': <String, dynamic>{
          'type': 'integer',
          'minimum': 0,
        },
        'refreshable': <String, dynamic>{
          'type': 'boolean',
          'default': false,
        },
        'preserveStateOnRefresh': <String, dynamic>{
          'type': 'boolean',
          'default': true,
        },
        'dataContext': <String, dynamic>{
          'type': 'object',
          'additionalProperties': true,
        },
        'asyncSources': <String, dynamic>{
          'type': 'object',
          'additionalProperties': <String, dynamic>{
            r'$ref': r'#/$defs/AsyncSource',
          },
        },
        'layout': <String, dynamic>{
          r'$ref': r'#/$defs/ResponsiveLayoutConfig',
        },
        'zones': <String, dynamic>{
          'type': 'object',
          'additionalProperties': <String, dynamic>{
            r'$ref': r'#/$defs/ContentZone',
          },
        },
      },
      r'$defs': <String, dynamic>{
        'AsyncSource': <String, dynamic>{
          'type': 'object',
          'required': <String>['endpoint'],
          'properties': <String, dynamic>{
            'endpoint': <String, dynamic>{'type': 'string', 'minLength': 1},
            'method': <String, dynamic>{
              'type': 'string',
              'enum': <String>['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
              'default': 'GET',
            },
            'headers': <String, dynamic>{
              'type': 'object',
              'additionalProperties': <String, dynamic>{'type': 'string'},
            },
            'ttlSeconds': <String, dynamic>{'type': 'integer', 'minimum': 0},
            'fallback': <String, dynamic>{
              'type': 'object',
              'additionalProperties': true,
            },
          },
        },
        'ResponsiveLayoutConfig': <String, dynamic>{
          'type': 'object',
          'required': <String>['mobile'],
          'properties': <String, dynamic>{
            'mobile': <String, dynamic>{r'$ref': r'#/$defs/BreakpointLayout'},
            'tablet': <String, dynamic>{r'$ref': r'#/$defs/BreakpointLayout'},
            'desktop': <String, dynamic>{r'$ref': r'#/$defs/BreakpointLayout'},
          },
        },
        'BreakpointLayout': <String, dynamic>{
          'type': 'object',
          'required': <String>['type'],
          'properties': <String, dynamic>{
            'type': <String, dynamic>{
              'type': 'string',
              'enum': <String>['single_column', 'grid_12_cols'],
              'default': 'single_column',
            },
            'zonesOrder': <String, dynamic>{
              'type': 'array',
              'items': <String, dynamic>{'type': 'string'},
            },
            'columns': <String, dynamic>{
              'type': 'array',
              'items': <String, dynamic>{r'$ref': r'#/$defs/ColumnSpanConfig'},
            },
          },
        },
        'ColumnSpanConfig': <String, dynamic>{
          'type': 'object',
          'required': <String>['span', 'zones'],
          'properties': <String, dynamic>{
            'span': <String, dynamic>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 12,
            },
            'zones': <String, dynamic>{
              'type': 'array',
              'items': <String, dynamic>{'type': 'string'},
            },
          },
        },
        'ContentZone': <String, dynamic>{
          'type': 'object',
          'required': <String>['modules'],
          'properties': <String, dynamic>{
            'pinned': <String, dynamic>{'type': 'boolean', 'default': false},
            'stickyBottom': <String, dynamic>{
              'type': 'boolean',
              'default': false,
            },
            'visibleWhen': <String, dynamic>{'type': 'string'},
            'padding': <String, dynamic>{
              'oneOf': <Map<String, dynamic>>[
                <String, dynamic>{'type': 'string'},
                <String, dynamic>{'type': 'number'},
                <String, dynamic>{'type': 'object'},
              ],
            },
            'modules': <String, dynamic>{
              'type': 'array',
              'items': <String, dynamic>{r'$ref': r'#/$defs/ModuleNode'},
            },
          },
        },
        'ModuleNode': <String, dynamic>{
          'type': 'object',
          'required': <String>['id', 'type'],
          'properties': moduleNodeProperties,
        },
        'A11yConfig': <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'label': <String, dynamic>{'type': 'string'},
            'hint': <String, dynamic>{'type': 'string'},
            'isButton': <String, dynamic>{'type': 'boolean', 'default': false},
            'isHeader': <String, dynamic>{'type': 'boolean', 'default': false},
            'excludeSemantics': <String, dynamic>{
              'type': 'boolean',
              'default': false,
            },
          },
        },
        'ActionNode': <String, dynamic>{
          'type': 'object',
          'required': <String>['actionType'],
          'properties': <String, dynamic>{
            'actionType': <String, dynamic>{
              'type': 'string',
              'enum': <String>[
                'navigation',
                'external_url',
                'state_mutation',
                'modal_zone',
                'scroll_to',
                'analytics_only',
                'custom_command',
              ],
            },
            'target': <String, dynamic>{'type': 'string'},
            'concurrency': <String, dynamic>{
              'type': 'string',
              'enum': <String>[
                'dropIfBusy',
                'debounce',
                'throttle',
                'allowParallel',
              ],
              'default': 'dropIfBusy',
            },
            'debounceMs': <String, dynamic>{
              'type': 'integer',
              'minimum': 0,
              'default': 300,
            },
            'payload': <String, dynamic>{
              'type': 'object',
              'additionalProperties': true,
            },
            'optimisticState': <String, dynamic>{
              r'$ref': r'#/$defs/OptimisticMutation',
            },
            'analytics': <String, dynamic>{
              'type': 'object',
              'additionalProperties': true,
            },
            'onSuccess': <String, dynamic>{r'$ref': r'#/$defs/ActionNode'},
            'onError': <String, dynamic>{r'$ref': r'#/$defs/ActionNode'},
          },
        },
        'OptimisticMutation': <String, dynamic>{
          'type': 'object',
          'required': <String>['key', 'value'],
          'properties': <String, dynamic>{
            'key': <String, dynamic>{'type': 'string'},
            'value': <String, dynamic>{},
            'rollbackOnError': <String, dynamic>{
              'type': 'boolean',
              'default': true,
            },
          },
        },
        'RepeaterConfig': <String, dynamic>{
          'type': 'object',
          'required': <String>['itemsDataPath', 'itemTemplate'],
          'properties': <String, dynamic>{
            'layoutMode': <String, dynamic>{
              'type': 'string',
              'enum': <String>['list', 'grid'],
              'default': 'list',
            },
            'crossAxisCount': <String, dynamic>{
              'oneOf': <Map<String, dynamic>>[
                <String, dynamic>{'type': 'integer', 'minimum': 1},
                <String, dynamic>{'type': 'object'},
              ],
            },
            'itemsDataPath': <String, dynamic>{'type': 'string'},
            'pagination': <String, dynamic>{
              r'$ref': r'#/$defs/PaginationConfig',
            },
            'itemTemplate': <String, dynamic>{r'$ref': r'#/$defs/ModuleNode'},
          },
        },
        'PaginationConfig': <String, dynamic>{
          'type': 'object',
          'required': <String>['endpoint'],
          'properties': <String, dynamic>{
            'endpoint': <String, dynamic>{'type': 'string'},
            'pageParam': <String, dynamic>{
              'type': 'string',
              'default': 'page',
            },
            'pageSize': <String, dynamic>{
              'type': 'integer',
              'minimum': 1,
              'default': 20,
            },
          },
        },
        if (modulePropsDefs.isNotEmpty) 'ModulePropsSchemas': modulePropsDefs,
      },
    };
  }

  /// Generates a formatted JSON string representing `cms_schema.json`.
  static String generateJsonString({
    Iterable<SduiModule> modules = const <SduiModule>[],
    bool pretty = true,
  }) {
    final map = generate(modules: modules);
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(map);
    }
    return jsonEncode(map);
  }
}
