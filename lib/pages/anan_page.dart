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
  TemplateImageType selectedImageType = TemplateImageType.base;

  Future<void> _loadImage(TemplateImageType imageType) async {
    final image = await _loadTemplateImage(imageType);
    if (mounted) {
      setState(() {
        _templateImage = image;
      });
    }
  }

  Future<ui.Image> _loadTemplateImage(TemplateImageType imageType) async {
    final data = await rootBundle.load('assets/anan/${imageType.assetName}');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void initState() {
    super.initState();
    _loadImage(selectedImageType); // 初始化时加载默认底图
  }

  void _onGeneratePressed() {
    String inputText = _textController.text.trim();
    final int maxChars = 50;

    if (inputText.length > maxChars) {
      // 如果输入的文本超过了最大字符数，则截断文本，并在末尾添加省略号
      inputText = '${inputText.substring(0, maxChars)}……';
    }

    setState(() {
      _displayText = inputText;
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButton<TemplateImageType>(
                  value: selectedImageType,
                  items: TemplateImageType.values.map((TemplateImageType type) {
                    return DropdownMenuItem<TemplateImageType>(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (TemplateImageType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedImageType = newValue;
                        _loadImage(newValue); // 根据选择加载对应的底图
                      });
                    }
                  },
                ),
              ),
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

enum TemplateImageType {
  base('anan_base.png'),
  happy('anan_happy.png'),
  speechless('anan_speechless.png'),
  yandere('anan_yandere.png'),
  blush('anan_blush.png'),
  angry('anan_angry.png');

  final String assetName;
  const TemplateImageType(this.assetName);
}

class MemePainter extends CustomPainter {
  final ui.Image templateImage;
  final String text;

  // 定义最大和最小字体大小占图片高度的比例
  final double maxFontSizeRatio = 0.08; // 最大字号为图片高度的8%
  final double minFontSizeRatio = 0.04; // 最小字号为图片高度的4%

  MemePainter({required this.templateImage, required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    double imgAspectRatio = templateImage.width / templateImage.height;
    double canvasAspectRatio = size.width / size.height;

    double drawWidth, drawHeight;
    if (canvasAspectRatio > imgAspectRatio) {
      drawHeight = size.height;
      drawWidth = drawHeight * imgAspectRatio;
    } else {
      drawWidth = size.width;
      drawHeight = drawWidth / imgAspectRatio;
    }

    double dx = (size.width - drawWidth) / 2;
    double dy = (size.height - drawHeight) / 2;

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
      final textRectLTRB = [
        Offset(drawWidth * 0.18 + dx, drawHeight * 0.75 + dy), // 左上角
        Offset(drawWidth * 0.78 + dx, drawHeight * 0.9 + dy), // 右下角
      ];

      final maxWidth = textRectLTRB[1].dx - textRectLTRB[0].dx;
      final maxHeight = textRectLTRB[1].dy - textRectLTRB[0].dy;

      // 根据图片高度动态计算最大和最小字号
      double maxFontSize = drawHeight * maxFontSizeRatio;
      double minFontSize = drawHeight * minFontSizeRatio;

      double fontSize = maxFontSize; // 初始字体大小为最大字号
      TextPainter textPainter;
      do {
        fontSize -= 1;
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
          fontSize > minFontSize);

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
