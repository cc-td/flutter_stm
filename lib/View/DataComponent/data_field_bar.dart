import 'package:flutter/material.dart';
import '../../Model/data.dart';

class DataFieldBar extends StatefulWidget {
  final List<DeviceFieldOption> fields;
  final String? selectedFieldKey;
  final Color activeColor;
  final ValueChanged<String> onFieldSelected;

  const DataFieldBar({
    super.key,
    required this.fields,
    required this.selectedFieldKey,
    required this.activeColor,
    required this.onFieldSelected,
  });

  @override
  State<DataFieldBar> createState() => _DataFieldBarState();
}

class _DataFieldBarState extends State<DataFieldBar> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _KeyFor(String key) {
    return _chipKeys.putIfAbsent(key, () => GlobalKey());
  }

  void _scrollToSelected() {
    final String? key = widget.selectedFieldKey;
    if (key == null) return;

    final BuildContext? ctx = _chipKeys[key]?.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  // 比较
  @override
  void didUpdateWidget(covariant DataFieldBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedFieldKey != oldWidget.selectedFieldKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.fields.map((field) {
          final bool isSelected = field.key == widget.selectedFieldKey;
          return Padding(
            key: _KeyFor(field.key),
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(field.label.isEmpty ? field.key : field.label),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: widget.activeColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => widget.onFieldSelected(field.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
