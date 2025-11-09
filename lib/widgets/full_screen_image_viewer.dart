import 'package:flutter/material.dart';
import 'dart:math' as math;

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images; // nazwy plików LUB pełne URL-e
  final int initialIndex;
  final String urlPrefix; // np. http://10.0.2.2:3000

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.urlPrefix,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _pageController;
  late int _index;

  // osobny controller zoomu na każdą stronę
  late final List<TransformationController> _tControllers;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
    _tControllers = List.generate(
      widget.images.length,
      (_) => TransformationController(),
    );
  }

  String _resolve(String name) {
    if (name.startsWith('http://') || name.startsWith('https://')) return name;
    if (name.startsWith('/')) return '${widget.urlPrefix}$name';
    return '${widget.urlPrefix}/uploads/$name';
  }

  double _scaleOf(TransformationController c) {
    // max z osi X/Y – prosta estymacja skali z macierzy
    final m = c.value.storage;
    final sx = math.sqrt(m[0] * m[0] + m[1] * m[1]);
    final sy = math.sqrt(m[4] * m[4] + m[5] * m[5]);
    return math.max(sx, sy);
  }

  void _resetZoom(int i) {
    _tControllers[i].value = Matrix4.identity();
    setState(() => _isZoomed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _index = i);
              // po zmianie strony zresetuj zoom nowej strony (komfort)
              _resetZoom(i);
            },
            itemCount: widget.images.length,
            itemBuilder: (context, i) {
              final url = _resolve(widget.images[i]);
              final tc = _tControllers[i];

              return GestureDetector(
                onDoubleTap: () {
                  // dwuklik: toggle 1x ↔ 2x
                  final current = _scaleOf(tc);
                  if (current > 1.02) {
                    _resetZoom(i);
                  } else {
                    tc.value = Matrix4.identity()..scale(2.0);
                    setState(() => _isZoomed = true);
                  }
                },
                child: Hero(
                  tag: url, // musi być ten sam co w gridzie
                  child: InteractiveViewer(
                    transformationController: tc,
                    minScale: 1.0,
                    maxScale: 4.0,
                    clipBehavior: Clip.none,
                    onInteractionEnd: (_) =>
                        setState(() => _isZoomed = _scaleOf(tc) > 1.02),
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 64,
                            width: 64,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // przycisk zamknięcia
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // indeks (np. 3/10)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
