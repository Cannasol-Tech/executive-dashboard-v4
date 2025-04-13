import 'package:flutter/material.dart';
import '../../../shared/theme/theme_constants.dart';

/// Widget that previews a color palette with various UI elements
class ColorPalettePreview extends StatelessWidget {
  /// Primary color for the palette
  final Color primaryColor;
  
  /// Secondary color for the palette
  final Color secondaryColor;

  /// Creates a color palette preview 
  const ColorPalettePreview({
    Key? key,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeConstants.obsidian;
    final backgroundColor = ThemeConstants.moonlight;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color Palette Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ThemeConstants.spaceMedium),
            
            // Color swatches
            Row(
              children: [
                Expanded(
                  child: _buildColorSwatch(
                    context: context,
                    color: primaryColor,
                    label: 'Primary',
                  ),
                ),
                const SizedBox(width: ThemeConstants.spaceMedium),
                Expanded(
                  child: _buildColorSwatch(
                    context: context,
                    color: secondaryColor,
                    label: 'Secondary',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spaceLarge),
            const Divider(),
            const SizedBox(height: ThemeConstants.spaceMedium),
            
            // UI Elements preview
            Text(
              'UI Elements',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: ThemeConstants.spaceMedium),
            
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                border: Border.all(color: ThemeConstants.silver),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar preview
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusSM),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spaceMedium,
                      vertical: ThemeConstants.spaceSmall,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu,
                          color: _getContrastColor(primaryColor),
                          size: 24,
                        ),
                        const SizedBox(width: ThemeConstants.spaceMedium),
                        Text(
                          'App Bar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getContrastColor(primaryColor),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.search,
                          color: _getContrastColor(primaryColor),
                          size: 24,
                        ),
                        const SizedBox(width: ThemeConstants.spaceSmall),
                        Icon(
                          Icons.more_vert,
                          color: _getContrastColor(primaryColor),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spaceMedium),
                  
                  // Button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Primary button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.spaceMedium,
                          vertical: ThemeConstants.spaceSmall,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            color: _getContrastColor(primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Outlined button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.spaceMedium,
                          vertical: ThemeConstants.spaceSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                        ),
                        child: Text(
                          'Outlined',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Text button
                      Text(
                        'Text Button',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: ThemeConstants.spaceMedium),
                  
                  // Card preview
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                      boxShadow: ThemeConstants.elevation2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.analytics,
                                color: _getContrastColor(secondaryColor),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: ThemeConstants.spaceSmall),
                            Text(
                              'Card Title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.more_horiz,
                              color: ThemeConstants.slate,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: ThemeConstants.spaceSmall),
                        Container(
                          height: 2,
                          color: secondaryColor.withOpacity(0.2),
                        ),
                        const SizedBox(height: ThemeConstants.spaceSmall),
                        Text(
                          'Card content with your selected colors',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spaceMedium),
                  
                  // Input field preview
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spaceMedium,
                      vertical: ThemeConstants.spaceSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: ThemeConstants.spaceSmall),
                        Text(
                          'Search...',
                          style: TextStyle(
                            color: ThemeConstants.slate,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spaceMedium),
                  
                  // Selection controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Checkbox
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
                            ),
                            child: Icon(
                              Icons.check,
                              color: _getContrastColor(secondaryColor),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: ThemeConstants.spaceTiny),
                          Text(
                            'Checkbox',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      
                      // Radio
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                              border: Border.all(color: secondaryColor, width: 2),
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: ThemeConstants.spaceTiny),
                          Text(
                            'Radio',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      
                      // Switch
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 20,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: ThemeConstants.spaceTiny),
                          Text(
                            'Switch',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSwatch({
    required BuildContext context,
    required Color color,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: ThemeConstants.spaceTiny),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
            boxShadow: ThemeConstants.elevation1,
          ),
          alignment: Alignment.center,
          child: Text(
            color.value.toRadixString(16).toUpperCase().substring(2),
            style: TextStyle(
              color: _getContrastColor(color),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: ThemeConstants.spaceTiny),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
              ),
            ),
            const SizedBox(width: ThemeConstants.spaceTiny),
            Text(
              '20%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: ThemeConstants.spaceSmall),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
              ),
            ),
            const SizedBox(width: ThemeConstants.spaceTiny),
            Text(
              '50%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
  
  /// Returns either black or white depending on which provides better contrast with [color]
  Color _getContrastColor(Color color) {
    // Calculate the perceptive luminance (human eye favors green color)
    final double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    
    // If luminance is > 0.5, use black text, otherwise white
    return luminance > 0.5 ? ThemeConstants.midnight : ThemeConstants.snowWhite;
  }
}