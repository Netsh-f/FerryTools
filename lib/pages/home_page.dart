import 'package:ferrytools/pages/lotto_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildToolTile(
          context: context,
          icon: Icons.casino,
          title: '乐透号码生成器',
          subtitle: '选取幸运数字，祝你中大奖！',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LottoPage())),
        ),
        _buildToolTile(
          context: context,
          icon: Icons.calculate,
          title: '其他小工具',
          subtitle: '敬请期待...',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LottoPage())),
        ),
        // 继续添加更多工具...
      ],
    );
  }

  Widget _buildToolTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
