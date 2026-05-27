---
name: PropTrack Design System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#44474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#75777e'
  outline-variant: '#c5c6ce'
  surface-tint: '#505f7b'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#0c1b34'
  on-primary-container: '#7684a2'
  inverse-primary: '#b8c7e8'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#001a42'
  on-tertiary-container: '#3980f4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e3ff'
  primary-fixed-dim: '#b8c7e8'
  on-primary-fixed: '#0c1b34'
  on-primary-fixed-variant: '#394762'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#d8e2ff'
  tertiary-fixed-dim: '#adc6ff'
  on-tertiary-fixed: '#001a42'
  on-tertiary-fixed-variant: '#004395'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-tabular:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1440px
  gutter: 24px
  margin-desktop: 48px
  margin-mobile: 16px
---

## Brand & Style
The design system is engineered for a high-fidelity fintech environment where precision meets accessibility. The brand personality is authoritative yet dynamic, combining the stability of traditional finance with the speed of modern technology. 

The visual style follows a **Modern Corporate** aesthetic with a heavy emphasis on **Data-Dense Minimalism**. This approach ensures that complex financial information is legible and actionable while maintaining an "airy" feel through strategic use of whitespace. The interface should feel premium and engineered, utilizing high-contrast elements to guide the user's focus through dense information architectures.

## Colors
The palette is anchored by a deep navy, establishing trust and depth. Vibrant emerald and electric blue function as high-energy accents for calls to action, success states, and data visualization.

- **Primary:** Navy (#0A1A33) is used for typography, navigation backgrounds, and primary branding.
- **Secondary:** Emerald (#10B981) is the "growth" color, used for success states and primary action highlights.
- **Tertiary:** Electric Blue (#3B82F6) serves as a secondary interactive color and for informational indicators.
- **Surface:** A cool off-white (#F8FAFC) reduces eye strain while maintaining a crisp, clinical cleanliness.
- **Gradients:** Use mesh gradients blending Navy and Emerald specifically for high-level status cards and hero action buttons to provide a sense of depth and modern energy.

## Typography
Inter is the sole typeface, chosen for its exceptional legibility in data-heavy contexts.

- **Headings:** Use Semi-Bold (600) weights to provide a strong visual anchor against the off-white background.
- **Numbers:** When displaying financial data, enable tabular figures (`tnum`) to ensure columns of numbers align perfectly for easy comparison.
- **Hierarchy:** Maintain a clear distinction between labels (uppercase, tracked out) and body text to help users scan forms and dashboards quickly.

## Layout & Spacing
The layout follows a **Fluid Grid** system within a max-width container of 1440px. 

- **Grid Model:** A 12-column system is used for desktop. 
- **Density:** We utilize a tight 24px gutter to maintain data density, but employ generous 48px outer margins on desktop to provide the "airy" feel required by the brand.
- **Rhythm:** All spacing is based on an 8px baseline. Use 16px (2x) for internal component padding and 32px (4x) or 48px (6x) for section vertical spacing. 
- **Reflow:** On mobile, the 12-column grid collapses to a 4-column layout with 16px gutters and margins.

## Elevation & Depth
This design system uses **Ambient Shadows** to create a sophisticated sense of depth without cluttering the UI with heavy borders.

- **Level 1 (Default):** Flat, 1px border (#E2E8F0) for static elements.
- **Level 2 (Cards/Dropdowns):** Multi-layered shadow: `0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1)`. This provides a soft, realistic lift.
- **Level 3 (Modals/Overlays):** Deep, diffused shadow: `0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04)`.
- **Tonal Depth:** Use surface layering (Off-white background vs. Pure White card surfaces) to differentiate content hierarchy before applying shadows.

## Shapes
The shape language balances professional rigidity with approachable modernity.

- **Cards:** Use a 16px (`rounded-lg`) corner radius to define the primary content containers.
- **Components:** Smaller interactive elements like buttons, input fields, and tags use a 12px radius. 
- **Consistency:** Never use fully sharp corners. The 12px/16px logic should be applied strictly to maintain a cohesive "friendly-professional" tone across the platform.

## Components
- **Buttons:** Primary buttons use a solid Navy background or a subtle Navy-to-Emerald mesh gradient. Labels are Semi-Bold Inter. Height should be 48px for standard actions.
- **Input Fields:** 12px radius, light gray border (#CBD5E1), and 16px internal horizontal padding. Active states utilize an Electric Blue glow.
- **Cards:** Pure white background, 16px radius, and Level 2 elevation. Padding should be a minimum of 24px.
- **Data Tables:** No vertical borders. Use thin horizontal separators (#F1F5F9). Headers use `label-md` typography.
- **Status Chips:** Small, 8px radius, using low-opacity versions of Emerald (Success) or Blue (Info) with high-contrast text.
- **Progress Indicators:** Use the Emerald gradient to represent growth or completion, contrasting against a light gray track.