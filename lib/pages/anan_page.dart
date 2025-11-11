import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class AnanPage extends StatefulWidget {
  const AnanPage({super.key});

  @override
  State<AnanPage> createState() => _AnanPageState();
}

class _AnanPageState extends State<AnanPage> {
  final TextEditingController _textController = TextEditingController();
  String _displayText = '';
  ui.Image? _templateImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final image = await _loadTemplateImage();
    if (mounted) {
      setState(() {
        _templateImage = image;
      });
    }
  }

  Future<ui.Image> _loadTemplateImage() async {
    final data = await rootBundle.load('assets/anan/anan_happy.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _onGeneratePressed() {
    setState(() {
      _displayText = _textController.text.trim();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = 541;

    return Scaffold(
      appBar: AppBar(title: const Text('夏目安安表情包生成器')),
      body: Center(
        // 居中布局
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 让Column只占用必要的空间
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 预览区域
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // 在图片下方添加间距
                  child: _templateImage == null
                      ? const Center(child: CircularProgressIndicator())
                      : CustomPaint(
                          painter: MemePainter(
                            templateImage: _templateImage!,
                            text: _displayText,
                          ),
                          size: Size.infinite,
                        ),
                ),
              ),

              // 输入框区域
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ), // 在输入框周围添加间距
                child: SizedBox(
                  width: imageWidth,
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '输入你想说的话...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _onGeneratePressed(),
                  ),
                ),
              ),
              // 按钮区域
              Padding(
                padding: const EdgeInsets.all(16.0), // 在按钮周围添加间距
                child: ElevatedButton(
                  onPressed: _onGeneratePressed,
                  child: const Text('生成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 自定义绘制器
class MemePainter extends CustomPainter {
  final ui.Image templateImage;
  final String text;

  MemePainter({required this.templateImage, required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    double imgAspectRatio = templateImage.width / templateImage.height; // 图片宽高比
    double canvasAspectRatio = size.width / size.height; // 当前画布宽高比

    double drawWidth, drawHeight;
    if (canvasAspectRatio > imgAspectRatio) {
      // 如果画布较宽
      drawHeight = size.height;
      drawWidth = drawHeight * imgAspectRatio;
    } else {
      // 如果画布较高
      drawWidth = size.width;
      drawHeight = drawWidth / imgAspectRatio;
    }

    // 计算居中位置
    double dx = (size.width - drawWidth) / 2;
    double dy = (size.height - drawHeight) / 2;

    // 绘制底图（按原比例缩放）
    canvas.drawImageRect(
      templateImage,
      Rect.fromLTWH(
        0,
        0,
        templateImage.width.toDouble(),
        templateImage.height.toDouble(),
      ),
      Rect.fromLTWH(dx, dy, drawWidth, drawHeight),
      Paint(),
    );

    if (text.isNotEmpty) {
      // 根据提供的相对坐标计算实际的矩形范围
      final textRectLTRB = [
        Offset(drawWidth * 0.18 + dx, drawHeight * 0.8 + dy), // 左上角
        Offset(drawWidth * 0.78 + dx, drawHeight * 0.9 + dy), // 右下角
      ];

      // 确定文本框的最大宽度和高度
      final maxWidth = textRectLTRB[1].dx - textRectLTRB[0].dx;
      final maxHeight = textRectLTRB[1].dy - textRectLTRB[0].dy;

      // 动态调整字体大小
      double fontSize = 40; // 初始字体大小
      TextPainter textPainter;
      do {
        fontSize -= 1; // 减小字体大小
        textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: maxWidth);
      } while ((textPainter.width > maxWidth ||
              textPainter.height > maxHeight) &&
          fontSize > 2); // 设置最小字号为10

      // 计算文本应该放置的位置以使其在指定矩形内居中
      final x = textRectLTRB[0].dx + (maxWidth - textPainter.width) / 2;
      final y = textRectLTRB[0].dy + (maxHeight - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant MemePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.templateImage != templateImage;
  }
}
