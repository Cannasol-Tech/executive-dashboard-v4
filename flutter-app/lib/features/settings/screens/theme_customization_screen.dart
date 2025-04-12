import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/theme_service.dart';
import '../widgets/color_palette_preview.dart';

/// Screen for customizing the application theme
class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({Key? key}) : super(key: key);

  @override
  _ThemeCustomizationScreenState createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _tempPrimaryColor = ThemeService.primaryColor;
  Color _tempSecondaryColor = ThemeService.secondaryColor;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Customization'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Presets', icon: Icon(Icons.palette_outlined)),
            Tab(text: 'Custom Colors', icon: Icon(Icons.color_lens_outlined)),
            Tab(text: 'Accessibility', icon: Icon(Icons.accessibility_new_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Presets tab
          _buildPresetsTab(themeProvider),
          
          // Custom colors tab
          _buildColorsTab(themeProvider, colorScheme),
          
          // Accessibility tab
          _buildAccessibilityTab(themeProvider, colorScheme),
        ],
      ),
    );
  }
  
  Widget _buildPresetsTab(ThemeProvider themeProvider) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
      children: [
        Text(
          'Theme Presets',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: ThemeConstants.spaceMedium),
        Text(
          'Select from our professionally designed theme presets for instant styling.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spaceLarge),
        _buildThemeModeSelector(themeProvider),
        const SizedBox(height: ThemeConstants.spaceLarge),
        
        // Theme presets grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: ThemeConstants.spaceMedium,
            mainAxisSpacing: ThemeConstants.spaceMedium,
          ),
          itemCount: ThemeService.themePresets.length,
          itemBuilder: (context, index) {
            final presetEntry = ThemeService.themePresets.entries.elementAt(index);
            final preset = presetEntry.value;
            final presetKey = presetEntry.key;
            
            return _buildPresetCard(
              presetKey: presetKey, 
              preset: preset,
              onTap: () => themeProvider.applyThemePreset(presetKey),
            );
          },
        ),
        
        const SizedBox(height: ThemeConstants.spaceLarge),
        ElevatedButton(
          onPressed: () => themeProvider.resetToDefaults(),
          child: const Text('Reset to Default Theme'),
        ),
      ],
    );
  }
  
  Widget _buildColorsTab(ThemeProvider themeProvider, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
      children: [
        Text(
          'Custom Colors',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: ThemeConstants.spaceMedium),
        Text(
          'Customize your theme with your brand\'s unique colors.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spaceLarge),
        
        // Color preview section
        ColorPalettePreview(
          primaryColor: themeProvider.primaryColor, 
          secondaryColor: themeProvider.secondaryColor,
        ),
        const SizedBox(height: ThemeConstants.spaceLarge),
        
        // Primary color picker
        Card(
          margin: const EdgeInsets.symmetric(vertical: ThemeConstants.spaceSmall),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ThemeConstants.spaceSmall),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showColorPicker(
                        context: context,
                        initialColor: themeProvider.primaryColor,
                        onColorChanged: (color) => setState(() => _tempPrimaryColor = color),
                        onColorConfirmed: themeProvider.setPrimaryColor,
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                          boxShadow: ThemeConstants.elevation1,
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spaceMedium),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Change'),
                      onPressed: () => _showColorPicker(
                        context: context,
                        initialColor: themeProvider.primaryColor,
                        onColorChanged: (color) => setState(() => _tempPrimaryColor = color),
                        onColorConfirmed: themeProvider.setPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Secondary color picker
        Card(
          margin: const EdgeInsets.symmetric(vertical: ThemeConstants.spaceSmall),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secondary Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ThemeConstants.spaceSmall),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showColorPicker(
                        context: context,
                        initialColor: themeProvider.secondaryColor,
                        onColorChanged: (color) => setState(() => _tempSecondaryColor = color),
                        onColorConfirmed: themeProvider.setSecondaryColor,
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: themeProvider.secondaryColor,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
                          boxShadow: ThemeConstants.elevation1,
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spaceMedium),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Change'),
                      onPressed: () => _showColorPicker(
                        context: context,
                        initialColor: themeProvider.secondaryColor,
                        onColorChanged: (color) => setState(() => _tempSecondaryColor = color),
                        onColorConfirmed: themeProvider.setSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spaceLarge),
        // Color palette suggestions
        Text(
          'Suggested Color Combinations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ThemeConstants.spaceSmall),
        Wrap(
          spacing: ThemeConstants.spaceSmall,
          runSpacing: ThemeConstants.spaceSmall,
          children: [
            _buildColorSuggestion(
              primary: ThemeConstants.deepOcean, 
              secondary: ThemeConstants.emeraldGleam,
              label: 'Default',
              themeProvider: themeProvider,
            ),
            _buildColorSuggestion(
              primary: ThemeConstants.royalAzure, 
              secondary: ThemeConstants.vibrantMagenta,
              label: 'Royal',
              themeProvider: themeProvider,
            ),
            _buildColorSuggestion(
              primary: ThemeConstants.emeraldGleam, 
              secondary: ThemeConstants.royalAzure,
              label: 'Fresh',
              themeProvider: themeProvider,
            ),
            _buildColorSuggestion(
              primary: ThemeConstants.deepOnyx, 
              secondary: ThemeConstants.electricSapphire,
              label: 'Modern',
              themeProvider: themeProvider,
            ),
            _buildColorSuggestion(
              primary: ThemeConstants.warmEmber, 
              secondary: ThemeConstants.deepOcean,
              label: 'Warm',
              themeProvider: themeProvider,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAccessibilityTab(ThemeProvider themeProvider, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
      children: [
        Text(
          'Accessibility Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: ThemeConstants.spaceMedium),
        Text(
          'Customize the interface to improve readability and usability.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spaceLarge),
        
        // High Contrast Mode
        SwitchListTile(
          title: Text(
            'High Contrast Mode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'Increases contrast between text and background',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          value: themeProvider.highContrast,
          onChanged: (value) => themeProvider.setHighContrast(value),
          secondary: const Icon(Icons.contrast),
        ),
        
        const Divider(),
        
        // Reduced Motion
        SwitchListTile(
          title: Text(
            'Reduced Motion',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'Minimizes animations throughout the interface',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          value: themeProvider.reducedMotion,
          onChanged: (value) => themeProvider.setReducedMotion(value),
          secondary: const Icon(Icons.animation),
        ),
        
        const Divider(),
        
        // Font Size Adjustment
        ListTile(
          title: Text(
            'Text Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'Adjust the size of text throughout the app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: const Icon(Icons.format_size),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spaceLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: themeProvider.fontSizeAdjust,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${(themeProvider.fontSizeAdjust * 100).round()}%',
                  onChanged: (value) => themeProvider.setFontSizeAdjust(value),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        
        const SizedBox(height: ThemeConstants.spaceLarge),
        const Divider(),
        const SizedBox(height: ThemeConstants.spaceLarge),
        
        // Text preview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ThemeConstants.spaceMedium),
                Text(
                  'Headlines look like this',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: ThemeConstants.spaceSmall),
                Text(
                  'This is how paragraph text looks. It should be easy to read with good contrast against the background.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: ThemeConstants.spaceSmall),
                Text(
                  'Smaller text is used for secondary information and should still be readable.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: ThemeConstants.spaceSmall),
                Text(
                  'Caption text is the smallest text that should be used in the interface.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPresetCard({
    required String presetKey,
    required ThemePreset preset,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLG),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ThemeConstants.spaceSmall),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: preset.primary,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusSM),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: preset.secondary,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusSM),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeConstants.spaceSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.check_circle_outline, size: 16),
                  SizedBox(width: ThemeConstants.spaceTiny),
                  Text('Apply'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeModeSelector(ThemeProvider themeProvider) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ThemeConstants.spaceSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeModeOption(
                  label: 'Light',
                  icon: Icons.light_mode,
                  mode: ThemeMode.light,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
                _buildThemeModeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode,
                  mode: ThemeMode.dark,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
                _buildThemeModeOption(
                  label: 'System',
                  icon: Icons.settings_suggest,
                  mode: ThemeMode.system,
                  currentMode: themeProvider.themeMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeModeOption({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.spaceSmall,
          horizontal: ThemeConstants.spaceMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: ThemeConstants.spaceTiny),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSuggestion({
    required Color primary,
    required Color secondary,
    required String label,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: () {
        themeProvider.setPrimaryColor(primary);
        themeProvider.setSecondaryColor(secondary);
      },
      borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(ThemeConstants.spaceSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeConstants.radiusSM),
                  topRight: Radius.circular(ThemeConstants.radiusSM),
                ),
              ),
            ),
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(ThemeConstants.radiusSM),
                  bottomRight: Radius.circular(ThemeConstants.radiusSM),
                ),
              ),
            ),
            const SizedBox(height: ThemeConstants.spaceTiny),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showColorPicker({
    required BuildContext context,
    required Color initialColor,
    required ValueChanged<Color> onColorChanged,
    required ValueChanged<Color> onColorConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = initialColor;
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
                onColorChanged(color);
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsl,
              pickerAreaBorderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                onColorConfirmed(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}