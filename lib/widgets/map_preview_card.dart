import 'dart:math';
import 'package:flutter/material.dart';
import '../models/country_configuration.dart';
import '../theme/app_theme.dart';

class MapPreviewCard extends StatefulWidget {
  final CountryConfiguration config;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const MapPreviewCard({
    super.key,
    required this.config,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.index = 0,
  });

  @override
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryNeon.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background / Procedural Map Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ProceduralMapPainter(
                            seed: widget.config.id.hashCode,
                            primaryColor: AppTheme.primaryNeon,
                          ),
                        ),
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.9),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.config.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildCountryBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تعديل: ${_formatDate(widget.config.lastModified)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Menu Button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            color: AppTheme.cardDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: AppTheme.primaryNeon.withOpacity(0.3)),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                widget.onEdit();
                              } else if (value == 'delete') {
                                widget.onDelete();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit,
                                        size: 18, color: AppTheme.primaryNeon),
                                    SizedBox(width: 8),
                                    Text('تعديل',
                                        style: TextStyle(
                                            color: AppTheme.textPrimary)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18, color: AppTheme.warningRed),
                                    SizedBox(width: 8),
                                    Text('حذف',
                                        style: TextStyle(
                                            color: AppTheme.warningRed)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCountryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryNeon.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryNeon.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            color: AppTheme.primaryNeon,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.config.countries.length}',
            style: const TextStyle(
              color: AppTheme.primaryNeon,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProceduralMapPainter extends CustomPainter {
  final int seed;
  final Color primaryColor;

  ProceduralMapPainter({required this.seed, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()
      ..color = AppTheme.surfaceDark
      ..style = PaintingStyle.fill;

    // Draw dark background
    canvas.drawRect(Offset.zero & size, paint);

    // Draw some "regions" (polygons)
    final regionPaint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 5; i++) {
      // Random polygon
      final path = Path();
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      path.moveTo(startX, startY);

      for (int j = 0; j < 4; j++) {
        path.lineTo(
          (startX + (random.nextDouble() - 0.5) * 100).clamp(0, size.width),
          (startY + (random.nextDouble() - 0.5) * 100).clamp(0, size.height),
        );
      }
      path.close();
      canvas.drawPath(path, regionPaint);
      canvas.drawPath(path, borderPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    double gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
