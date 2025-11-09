import 'package:flutter/material.dart';
import 'package:ferrytools/widgets/tool_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<Map<String, dynamic>> _tools = [
    {'title': '大乐透', 'icon': Icons.code},
    {'title': '双色球', 'icon': Icons.casino},
    {'title': '七乐彩', 'icon': Icons.casino},
    {'title': '七星彩', 'icon': Icons.casino},
    {'title': '排列三', 'icon': Icons.casino},
    {'title': '排列五', 'icon': Icons.casino},
    {'title': '福彩3D', 'icon': Icons.casino},
    {'title': '快乐8', 'icon': Icons.casino},
    {'title': '竞彩足球', 'icon': Icons.sports_soccer},
    {'title': '竞彩足球', 'icon': Icons.sports_soccer},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              final width = constraints.maxWidth;
              if (width < 300) {
                crossAxisCount = 1;
              } else if (width < 500) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 3;
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _tools.length,
                itemBuilder: (context, index) {
                  final tool = _tools[index];
                  return ToolCard(
                    title: tool['title'] as String,
                    icon: tool['icon'] as IconData,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}