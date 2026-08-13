import 'package:flutter/material.dart';

class EmojiProfilePicker extends StatefulWidget {
  final String initialEmoji;
  final Function(String) onEmojiSelected;

  const EmojiProfilePicker({
    super.key, 
    required this.initialEmoji, 
    required this.onEmojiSelected,
  });

  @override
  State<EmojiProfilePicker> createState() => _EmojiProfilePickerState();
}

class _EmojiProfilePickerState extends State<EmojiProfilePicker> {
  late String selectedEmoji;

  final List<String> availableEmojis = [
    '😀', '😎', '🤓', '🤠', '🥳', '👽',
    '🤖', '👻', '🦊', '🐶', '🐱', '🦄',
    '🚀', '🎸', '⚽', '🍔', '🍕', '☕',
    '🦁', '🐼', '🐨', '🐯', '🐸', '🐵',
    '⭐', '🌟', '🔥', '⚡', '🌈', '💎',
  ];

  @override
  void initState() {
    super.initState();
    selectedEmoji = widget.initialEmoji;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Displayed Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Text(
              selectedEmoji,
              style: const TextStyle(fontSize: 50),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose an Avatar',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // The Grid of Options
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableEmojis.length,
              itemBuilder: (context, index) {
                final emoji = availableEmojis[index];
                final isSelected = emoji == selectedEmoji;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoji = emoji;
                    });
                    widget.onEmojiSelected(emoji);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: theme.colorScheme.primary, width: 2) 
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
