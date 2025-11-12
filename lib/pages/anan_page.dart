import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_html/html.dart' as html;

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
  final GlobalKey _repaintBoundaryKey = GlobalKey();

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

  Future<void> _exportImage() async {
    // 获取 RepaintBoundary 状态
    RenderRepaintBoundary? boundary =
        _repaintBoundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null) return;

    // 将 RepaintBoundary 转换为图像
    ui.Image image = await boundary.toImage(pixelRatio: 2.0); // 提高清晰度

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    Uint8List pngBytes = byteData.buffer.asUint8List();

    // 创建 Blob 对象并生成下载链接
    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        'anan_meme_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    anchor.click();
    html.Url.revokeObjectUrl(url);
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
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DropdownButton放在左边
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 8.0,
                      ), // 给DropdownButton右边添加一些间距
                      child: DropdownButton<TemplateImageType>(
                        value: selectedImageType,
                        items: TemplateImageType.values.map((
                          TemplateImageType type,
                        ) {
                          return DropdownMenuItem<TemplateImageType>(
                            value: type,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                type.cnName,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (TemplateImageType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedImageType = newValue;
                              _loadImage(newValue);
                            });
                          }
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        underline: Container(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // 生成按钮放在右边
                    ElevatedButton(
                      onPressed: _onGeneratePressed,
                      child: const Text('生成'),
                    ),
                    const SizedBox(width: 8), // 间距
                    ElevatedButton(
                      onPressed: _displayText.isEmpty
                          ? null
                          : _exportImage, // 无文字时禁用
                      child: const Text('下载'),
                    ),
                  ],
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
  base('anan_base.png', '正常'),
  happy('anan_happy.png', '开心'),
  speechless('anan_speechless.png', '无语'),
  yandere('anan_yandere.png', '病娇'),
  blush('anan_blush.png', '脸红'),
  angry('anan_angry.png', '生气');

  final String assetName;
  final String cnName;
  const TemplateImageType(this.assetName, this.cnName);
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
