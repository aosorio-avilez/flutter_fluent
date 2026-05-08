import 'dart:async';

import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that displays the details of the current environment.
///
/// It shows the environment's name, type, color, and all configuration values
/// defined in [Environment.values].
class EnvironmentInspector extends StatelessWidget {
  /// Creates an [EnvironmentInspector].
  const EnvironmentInspector({
    required this.environmentApi,
    this.configValuesLabel = 'Configuration Values',
    this.noValuesLabel = 'No configuration values defined.',
    super.key,
  });

  /// The environment API to use.
  final EnvironmentApi environmentApi;

  /// The label for the configuration values section.
  final String configValuesLabel;

  /// The message to display when no configuration values are defined.
  final String noValuesLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: ValueListenableBuilder<Environment>(
        valueListenable: environmentApi.environmentNotifier,
        builder: (context, environment, _) {
          final sensitiveKeys = environment.sensitiveKeys
              .map((e) => e.toLowerCase())
              .toSet();

          return Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: environment.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        environment.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          environment.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (environmentApi.availableEnvironments.length > 1) ...[
                    Text(
                      'Available Environments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: environmentApi.availableEnvironments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final env =
                              environmentApi.availableEnvironments[index];
                          final isSelected = env == environment;

                          return ChoiceChip(
                            label: Text(env.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                environmentApi.updateEnvironment(env);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                  Text(
                    configValuesLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (environment.values.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(noValuesLabel),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: environment.values.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final key = environment.values.keys.elementAt(index);
                        final value = environment.values[key];
                        final isSensitive = sensitiveKeys.contains(
                          key.toLowerCase(),
                        );
                        final stringValue = isSensitive
                            ? '***REDACTED***'
                            : (value ?? 'N/A');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      key,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    SelectableText(
                                      stringValue,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'monospace',
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (value != null && !isSensitive)
                                IconButton(
                                  icon: const Icon(Icons.copy_all, size: 20),
                                  tooltip: 'Copy "$key" to clipboard',
                                  onPressed: () {
                                    unawaited(
                                      Clipboard.setData(
                                        ClipboardData(text: stringValue),
                                      ),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Copied "$key" to clipboard',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
