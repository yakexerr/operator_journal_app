import 'package:flutter/material.dart';

class FormulaPopScope extends StatelessWidget {
  // список всех контроллеров на странице (их может быть несколько)
  final List<TextEditingController> controllers;
  final Widget child;

  const FormulaPopScope({
    super.key,
    required this.controllers,
    required this.child,
  });

  // метод для проверки: заполнено ли хотя бы одно поле?
  bool _hasAnyData() {
    return controllers.any((controller) => controller.text.isNotEmpty);
  }

  // диалог подтверждения
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Выход из задачи"),
            content: const Text("У вас есть введённые данные. Вы уверены, что хотите выйти? Данные будут потеряны."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Не выходить
                child: const Text("ОСТАТЬСЯ"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Выйти
                child: const Text("ВЫЙТИ", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false; // Если закрыли диалог тапом мимо — возвращаем false
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: true означает, что система выпустит пользователя сразу
      canPop: !_hasAnyData(), 
      onPopInvokedWithResult: (didPop, result) async {
        //если didPop == true, значит мы уже вышли (поля были пустые)
        if (didPop) return;

        // если поля не пустые, вызывается диалог
        final bool shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child, // сюда придет Scaffold страницы
    );
  }
}