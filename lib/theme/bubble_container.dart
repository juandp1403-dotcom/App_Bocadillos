import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Contenedor inflado estilo Y2K con esquinas redondeadas, borde ocre,
/// sombra suave, gradiente opcional y un reflejo blanco curvo arriba a la
/// izquierda (tipo burbuja).
///
/// Variantes de gradiente:
/// - [BubbleContainer.calido]: rojo -> rosa chicle.
/// - [BubbleContainer.pastel]: beige -> azul pastel.
class BubbleContainer extends StatelessWidget {
  const BubbleContainer({
    super.key,
    required this.child,
    this.gradient = const [AppColors.rojo, AppColors.rosa],
    this.borderColor = AppColors.ocre,
    this.borderWidth = 1.5,
    this.radius = 32,
    this.padding = const EdgeInsets.all(16),
    this.shadowColor = const Color(0x335B3A29),
  });

  const BubbleContainer.calido({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  }) : gradient = const [AppColors.rojo, AppColors.rosa],
       borderColor = AppColors.ocre,
       borderWidth = 1.5,
       radius = 32,
       shadowColor = const Color(0x335B3A29);

  const BubbleContainer.pastel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  }) : gradient = const [AppColors.beige, AppColors.azul],
       borderColor = AppColors.ocre,
       borderWidth = 1.5,
       radius = 32,
       shadowColor = const Color(0x335B3A29);

  final Widget child;
  final List<Color> gradient;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final redondeo = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: redondeo,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: redondeo,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: redondeo,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
              ),
            ),
            // Reflejo blanco semitransparente y curvo (burbuja).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _ReflejoCurvoClipper(),
                child: Container(
                  height: radius * 1.2 + 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.reflejo, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.85),
                      width: borderWidth,
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Dibuja el brillo curvo que evoca la burbuja en la parte superior.
class _ReflejoCurvoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 1.1,
        size.width * 0.38,
        size.height * 0.62,
      )
      ..lineTo(0, size.height * 0.2)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
