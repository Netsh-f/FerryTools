import 'dart:math';
import 'package:flutter/material.dart';

class LottoPage extends StatefulWidget {
  const LottoPage({super.key});

  @override
  State<LottoPage> createState() => _LottoPageState();
}

class _LottoPageState extends State<LottoPage> {
  List<List<String>> _lottoNumbers = [];

  // 生成一注大乐透号码
  List<String> _generateOneLotto() {
    final random = Random();

    // 前区：1-35 选 5 个不重复
    final frontPool = List<int>.generate(35, (i) => i + 1);
    frontPool.shuffle(random);
    final front = frontPool.take(5).toList()..sort();

    // 后区：1-12 选 2 个不重复
    final backPool = List<int>.generate(12, (i) => i + 1);
    backPool.shuffle(random);
    final back = backPool.take(2).toList()..sort();

    // 格式化为两位字符串
    final frontStr = front.map((n) => n.toString().padLeft(2, '0')).toList();
    final backStr = back.map((n) => n.toString().padLeft(2, '0')).toList();

    return [...frontStr, '+', ...backStr];
  }

  // 生成5注
  void _generateLotto() {
    final List<List<String>> results = [];
    for (int i = 0; i < 5; i++) {
      results.add(_generateOneLotto());
    }
    setState(() {
      _lottoNumbers = results;
    });
  }

  @override
  void initState() {
    super.initState();
    _generateLotto(); // 进入页面时自动生成一次
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('超级大乐透号码生成器'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var line in _lottoNumbers) _buildNumberLine(line),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ElevatedButton.icon(
              onPressed: _generateLotto,
              icon: const Icon(Icons.autorenew),
              label: const Text('生成', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberLine(List<String> parts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < parts.length; i++)
            if (parts[i] == '+')
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < 5 ? Colors.blue[50] : Colors.orange[50],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i < 5 ? Colors.blue : Colors.orange,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    parts[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: i < 5 ? Colors.blue[800] : Colors.orange[800],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
