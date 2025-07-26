import 'package:flutter/material.dart';

class ScrollableBottomSheet extends StatelessWidget {
  const ScrollableBottomSheet({
    required this.content,
    this.title,
    this.initialChildSize = 0.95,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.95,
    super.key,
  });

  final Widget content;
  final String? title;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, draggableScrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
              Flexible(
                child: SingleChildScrollView(
                  controller: draggableScrollController,
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
