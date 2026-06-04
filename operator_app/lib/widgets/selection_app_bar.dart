import 'package:flutter/material.dart';

// без этого implement шибку, так как Scaffold должен знать высоту AppBar еще до того, как он отрисован
// даём обещание тчо будет иметь заранее известный размер наш appBar
class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectionCount;
  final VoidCallback onClearSelection; // функция, которую мы вызовем при закрытии

  const SelectionAppBar({
    super.key,
    required this.selectionCount,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueGrey[800], // Выделим цветом режим выбора
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: onClearSelection, // Просто вызываем колбэк
      ),
      title: Text(
        '$selectionCount выбрано',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // обязательный метод для AppBar - реализация общещания про размер
  // kToolbarHeight - системная константа высоты AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}