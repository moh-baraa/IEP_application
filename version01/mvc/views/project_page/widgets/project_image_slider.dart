import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';

class ProjectImageSlider extends StatefulWidget {
  final List<String> images;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const ProjectImageSlider({
    super.key,
    required this.images,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ProjectImageSlider> createState() => _ProjectImageSliderState();
}

class _ProjectImageSliderState extends State<ProjectImageSlider> {
  int _currentIndex = 0;

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.images.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // === the image ===
            SizedBox.expand(
              child: widget.images.isNotEmpty
                  ? Image.network(
                      widget.images[_currentIndex],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),

            // === arrows show if there more than one image ===
            if (widget.images.length > 1) ...[
              Positioned(
                left: 8,
                top: (widget.height / 2) - 20, // moderate vertical
                child: _ArrowButton(
                  icon: Icons.arrow_back_ios,
                  onPressed: _prevImage,
                ),
              ),
              Positioned(
                right: 8,
                top: (widget.height / 2) - 20,
                child: _ArrowButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: _nextImage,
                ),
              ),
            ],

            // === image indicatior ===
            if (widget.images.length > 1)
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.text.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: TextStyle(color: colors.background, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// === arrow widget ===
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.light.text.withOpacity(0.8),
      radius: 16,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.light.background, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}
