# Design System - Premium Edition

This document outlines the sophisticated design standards, typography, colors, and UI patterns used throughout the Cannasol Technologies Executive Dashboard, creating a stunning visual experience.

## Elevated Color Palette

### Primary Colors

| Color Name | Hex Value | Usage |
|------------|-----------|-------|
| Deep Ocean | `#0A192F` | Main backgrounds, headers |
| Emerald Gleam | `#26D07C` | Primary actions, highlights |
| Royal Azure | `#0062FF` | Secondary actions, accent elements |
| Moonlight | `#F8F9FC` | Light mode background |
| Night Sky | `#070E1A` | Dark mode background |

### Accent Colors 

|=Color | Hex Value |
|----------|-------|-----------|
| Vibrant Magenta | `#C13584` |
| Deep Onyx | `#010101` |
| Warm Ember | `#FF4500` |
| Electric Sapphire | `#1DA1F2` |
| Vivid Crimson | `#FF0000` |

### Gradient Definitions

| Gradient Name | Definition | Usage |
|---------------|------------|-------|
| Premium Brand | Linear from Deep Ocean (#0A192F) to Teal Highlight (#26D07C) | App branding elements |
| Action Gradient | Radial from Emerald Gleam (#26D07C) to Deep Ocean (#0A192F) | Call to action buttons |
| Night Ocean | Linear from Night Sky (#070E1A) to Deep Ocean (#0A192F) | Navigation elements |
| Subtle Card | Faint linear from Moonlight (#F8F9FC) to White (#FFFFFF) | Card backgrounds |

### Neutral Colors

| Color | Hex Value | Usage |
|-------|-----------|-------|
| Snow White | `#FFFFFF` | Pure white surfaces |
| Whisper | `#F9FAFB` | Light backgrounds |
| Mist | `#F3F4F6` | Dividers, subtle backgrounds |
| Silver | `#E5E7EB` | Borders, separators |
| Smoke | `#D1D5DB` | Disabled states |
| Steel | `#9CA3AF` | Secondary text |
| Slate | `#6B7280` | Placeholder text |
| Graphite | `#4B5563` | Subtle text |
| Charcoal | `#374151` | Text |
| Obsidian | `#1F2937` | Headings |
| Midnight | `#111827` | High contrast text |

### Semantic Colors

| Color | Hex Value | Usage |
|-------|-----------|-------|
| Success Emerald | `#10B981` | Success states, positive metrics |
| Warning Amber | `#F59E0B` | Warning states, attention required |
| Error Ruby | `#EF4444` | Error states, critical alerts |
| Info Sapphire | `#3B82F6` | Information, neutral alerts |

## Sophisticated Typography

### Font Families

- **Primary Font**: Poppins (Sans-serif)
- **Secondary Font**: Inter (Sans-serif)
- **Accent Font**: Playfair Display (For headings and special elements)
- **Monospace Font**: JetBrains Mono (For code snippets and fixed-width content)

### Type Scale

| Name | Size (px) | Weight | Line Height | Font | Usage |
|------|-----------|--------|-------------|------|-------|
| Hero Display | 64 | Bold (700) | 1.1 | Playfair Display | Main page heroes |
| Display Large | 57 | Bold (700) | 1.2 | Poppins | Section introductions |
| Display Medium | 45 | Bold (700) | 1.2 | Poppins | Major headings |
| Display Small | 36 | Bold (700) | 1.2 | Poppins | Section headings |
| Headline Medium | 28 | SemiBold (600) | 1.3 | Poppins | Card headings |
| Title Large | 22 | SemiBold (600) | 1.3 | Inter | Strong emphasis |
| Title Medium | 18 | SemiBold (600) | 1.4 | Inter | Medium emphasis titles |
| Title Small | 16 | SemiBold (600) | 1.4 | Inter | Minor headings |
| Body Large | 16 | Regular (400) | 1.5 | Inter | Primary body text |
| Body Medium | 14 | Regular (400) | 1.5 | Inter | Secondary body text |
| Body Small | 12 | Regular (400) | 1.5 | Inter | Captions, annotations |
| Label | 12 | Medium (500) | 1.2 | Inter | Button labels, tags |

### Responsive Typography

Implement sophisticated type scaling:
- **Mobile**: Base scale (as defined above)
- **Tablet**: 1.1x scaling factor with refined spacing
- **Desktop**: 1.2x scaling factor with optimized line lengths

## Refined Spacing

### Spacing Scale

| Name | Size (px) | Usage |
|------|-----------|-------|
| Space Nano | 2 | Minimal separation |
| Space Micro | 4 | Tight spacing, thin borders |
| Space Tiny | 8 | Compact elements |
| Space Small | 12 | Related elements |
| Space Medium | 16 | Standard spacing |
| Space Large | 24 | Content separation |
| Space XL | 32 | Section separation |
| Space XXL | 48 | Major section dividers |
| Space 3XL | 64 | Layout zones |
| Space 4XL | 96 | Hero spacing |

### Layout Grid

- **Columns**: 12-column grid with 1px guide lines
- **Gutters**: 16px (mobile), 24px (tablet), 32px (desktop)
- **Margins**: 16px (mobile), 32px (tablet), 64px (desktop)
- **Grid visualization**: Subtle for development mode

## Sophisticated Elevation and Shadows

| Level | Definition | Usage |
|-------|------------|-------|
| Surface | No elevation | Background planes |
| Elevation 1 | `0 1px 2px rgba(0, 0, 0, 0.05)` | Subtle card elevation |
| Elevation 2 | `0 4px 6px -1px rgba(0, 0, 0, 0.07), 0 2px 4px -1px rgba(0, 0, 0, 0.05)` | Cards, dialogs |
| Elevation 3 | `0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -2px rgba(0, 0, 0, 0.05)` | Popovers, dropdowns |
| Elevation 4 | `0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)` | Modals, floating elements |
| Elevation 5 | `0 25px 50px -12px rgba(0, 0, 0, 0.25)` | Highest elevation elements |

## Border Radius

| Name | Size (px) | Usage |
|------|-----------|-------|
| Radius None | 0 | No rounding |
| Radius XS | 2 | Subtle rounding |
| Radius SM | 4 | Buttons, inputs |
| Radius MD | 8 | Cards, dialogs |
| Radius LG | 12 | Large cards, panels |
| Radius XL | 16 | Feature sections |
| Radius XXL | 24 | Hero elements |
| Radius Full | 9999px | Pills, avatars, badges |

## Animation System

### Duration

| Name | Duration (ms) | Usage |
|------|--------------|-------|
| Instant | 50 | Immediate feedback |
| Quick | 150 | Micro-interactions |
| Medium | 300 | Standard transitions |
| Slow | 500 | Large element transitions |
| Very Slow | 800 | Full-screen transitions |

### Easing Curves

| Name | Definition | Usage |
|------|------------|-------|
| Standard | `cubic-bezier(0.2, 0.0, 0.0, 1.0)` | Default animations |
| Entrance | `cubic-bezier(0.0, 0.0, 0.2, 1.0)` | Elements entering screen |
| Exit | `cubic-bezier(0.4, 0.0, 1.0, 1.0)` | Elements leaving screen |
| Bounce | `cubic-bezier(0.175, 0.885, 0.32, 1.275)` | Playful animations |
| Smooth | `cubic-bezier(0.645, 0.045, 0.355, 1.000)` | Refined movements |

### Animation Types

| Type | Description | Usage |
|------|-------------|-------|
| Fade | Opacity changes | Element appearance/disappearance |
| Scale | Size transforms | Emphasis, focus |
| Slide | Position changes | Panel shifts, content changes |
| Color | Color transitions | State changes, emphasis |
| Transform | Rotation/skew changes | Advanced interactions |

## Polished UI Components

### Buttons

| Type | Usage | Visual Treatment |
|------|-------|------------------|
| Primary | Main actions | Gradient fill with subtle hover animation |
| Secondary | Alternative actions | Outlined with animated hover fill |
| Tertiary | Low-emphasis actions | Text-only with underline animation |
| Icon | Compact actions | Icon with animated circular background |
| FAB | Important actions | Elevated button with shadow and hover effect |

### Form Elements

| Component | Usage | Visual Treatment |
|-----------|-------|------------------|
| Text Field | Text input | Animated border with floating label |
| Dropdown | Selection | Dynamic animation with elegant dropdown |
| Checkbox | Multi-select | Custom animated checkmark |
| Radio | Single selection | Animated selection indicator |
| Toggle | Binary options | Smooth sliding animation with color change |
| Slider | Range selection | Interactive track with animated thumb |

### Cards

| Type | Usage | Visual Treatment |
|------|-------|------------------|
| Metric Card | Single data point | Clean design with focused metric and trend |
| Chart Card | Data visualization | Elegant container with interactive chart |
| List Card | Multiple items | Clean list with subtle separators |
| Action Card | Interactive elements | Hover effects with smooth transitions |
| Profile Card | User information | Elegant layout with avatar and details |

## Microinteractions

| Element | Interaction | Animation |
|---------|-------------|-----------|
| Buttons | Hover | Subtle scale (1.02) and shadow increase |
| Buttons | Press | Quick scale down (0.98) |
| Cards | Hover | Subtle elevation increase |
| Toggle | Change | Smooth movement with color animation |
| Inputs | Focus | Border animation and subtle background change |
| Navigation | Selection | Smooth indicator movement and color transition |
| Charts | Data point hover | Elegant tooltip appearance and highlight |

## Advanced Visualization

### Charts and Graphs

| Type | Usage | Visual Style |
|------|-------|-------------|
| Line Chart | Trends over time | Smooth gradient lines with animated appearance |
| Bar Chart | Comparisons | Elegant bars with rounded corners and animations |
| Pie/Donut | Distribution | Gradient segments with hover interactions |
| Radar | Multi-dimension | Subtle grid with animated polygon |
| Heatmap | Density/distribution | Elegant color mapping with tooltips |
| Scatter | Correlation | Animated points with size variations |

### Data Presentation

| Element | Usage | Visual Style |
|---------|-------|-------------|
| Metrics | KPIs | Large, focused numbers with supporting context |
| Tables | Detailed data | Clean lines, subtle zebra striping, hover effects |
| Lists | Sequential information | Elegant spacing with subtle separators |
| Timeline | Sequential events | Connected nodes with position indicators |
| Progress | Completion status | Animated bars/circles with gradient fills |

## Accessibility

### Color Contrast

All color combinations exceed WCAG 2.1 AA standards:
- Text: Minimum contrast ratio of 4.5:1
- Large text: Minimum contrast ratio of 3:1
- UI components: Minimum contrast ratio of 3:1

### Focus States

All interactive elements have elegant focus states:
- 2px glow effect with brand color
- Subtle background shift
- Maintained visual cohesion with design system

### Modes

The application supports sophisticated visual modes:
- Elegant dark mode with reduced brightness
- High contrast mode for accessibility
- Reduced motion mode for vestibular disorders
- Customizable color modes with saved profiles

## Implementation

The design system is implemented through:
- `lib/src/shared/theme/theme_constants.dart` - Design constants
- `lib/config/theme.dart` - Theme implementation
- Shared component library with consistent styling
- Animation services for standardized motion

## Design Principles

1. **Clarity** - Information hierarchy is clear and purposeful
2. **Sophistication** - Visual elements are refined and premium
3. **Consistency** - Design patterns are cohesive throughout
4. **Delight** - Interactions surprise and please users
5. **Performance** - Animations and effects remain smooth and efficient
