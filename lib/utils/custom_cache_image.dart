import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCacheImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool? circularShape;
  final IconData? errorIcon;
  const CustomCacheImage({Key? key, required this.imageUrl, required this.radius, this.circularShape, this.errorIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
          bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) {
          if (url.isEmpty || url == 'null') {
            return Container(
              color: Colors.grey[300],
              child: Icon(errorIcon ?? Icons.error),
            );
          }

          return IgnorePointer(
            child: Image.network(
              imageUrl,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(errorIcon ?? Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
}
