import 'package:flutter/material.dart';

/// Reusable search / filter bar used on every devtools list screen.
class FFSearchBar extends StatefulWidget {
  /// Creates a search bar. [onChanged] fires on every keystroke.
  const FFSearchBar({
    required this.onChanged,
    this.hint = 'Search…',
    this.initialValue = '',
    super.key,
  });

  /// Called on every text change.
  final ValueChanged<String> onChanged;

  /// Placeholder shown when empty.
  final String hint;

  /// Starting value.
  final String initialValue;

  @override
  State<FFSearchBar> createState() => _FFSearchBarState();
}

class _FFSearchBarState extends State<FFSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                ),
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
