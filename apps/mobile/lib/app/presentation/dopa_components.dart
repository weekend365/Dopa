import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';

class DopaActionButton extends StatelessWidget {
  const DopaActionButton({
    required this.label,
    this.onPressed,
    this.busy = false,
    this.icon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        if (busy)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: MediaQuery.disableAnimationsOf(context) ? 0.65 : null,
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        Text(busy ? '잠시만 기다려 주세요…' : label, textAlign: TextAlign.center),
      ],
    ),
  );
}

class DopaNotice extends StatelessWidget {
  const DopaNotice({
    required this.message,
    this.onRetry,
    this.isError = false,
    super.key,
  });
  final String message;
  final VoidCallback? onRetry;
  final bool isError;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: isError,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : DopaSurfaces.of(context).muted,
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('다시 시도하기')),
        ],
      ),
    ),
  );
}

class DopaStep extends StatelessWidget {
  const DopaStep({
    required this.index,
    required this.total,
    required this.text,
    super.key,
  });
  final int index, total;
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DopaSurfaces.of(context).soft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1} / $total',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    ),
  );
}

class DopaRecordRow extends StatelessWidget {
  const DopaRecordRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onDelete,
    super.key,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: DopaSurfaces.of(context).muted),
              ),
            ],
          ),
        ),
        if (onDelete != null)
          IconButton(
            tooltip: '기록 삭제',
            onPressed: onDelete,
            icon: const Icon(Icons.more_horiz),
          ),
      ],
    ),
  );
}
