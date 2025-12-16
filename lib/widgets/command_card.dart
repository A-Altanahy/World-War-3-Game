// lib/widgets/command_card.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommandCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool glowEffect;
  final Color? glowColor;
  final bool animate;

  const CommandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.width,
    this.height,
    this.onTap,
    this.glowEffect = true,
    this.glowColor,
    this.animate = true,
  });

  @override
  State<CommandCard> createState() => _CommandCardState();
}

class _CommandCardState extends State<CommandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.005,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (widget.animate) {
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppTheme.primaryNeon;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardDark,
                      AppTheme.surfaceDark.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.glowEffect
                        ? glowColor.withOpacity(_glowAnimation.value)
                        : AppTheme.primaryNeon.withOpacity(0.3),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: widget.glowEffect
                      ? [
                          BoxShadow(
                            color: glowColor
                                .withOpacity(_glowAnimation.value * 0.2),
                            blurRadius: _isHovered ? 8 : 6,
                            spreadRadius: _isHovered ? 1 : 0,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : AppTheme.neonShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool enabled;
  final bool loading;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.enabled = true,
    this.loading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled && !widget.loading) {
      // Disable automatic pulsing animation to reduce noise
      // _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppTheme.primaryNeon;
    final buttonTextColor = widget.textColor ?? Colors.black;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
            if (widget.enabled && !widget.loading && widget.onPressed != null) {
              widget.onPressed!();
            }
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.width,
            height: widget.height ?? 50,
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              gradient: widget.enabled && !widget.loading
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        buttonColor,
                        buttonColor.withOpacity(0.8),
                      ],
                    )
                  : null,
              color: widget.enabled && !widget.loading
                  ? null
                  : AppTheme.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.enabled && !widget.loading
                    ? buttonColor.withOpacity(_glowAnimation.value)
                    : AppTheme.textMuted.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: widget.enabled && !widget.loading
                  ? [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: buttonTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AppTheme.darkBackground,
          AppTheme.surfaceDark,
          AppTheme.surfaceLight,
        ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -1.0 + (_animation.value * 2.0),
                -1.0 + (_animation.value * 2.0),
              ),
              radius: 1.5 + (_animation.value * 0.5),
              colors: colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
