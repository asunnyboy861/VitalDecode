# VitalDecode - iOS Development Guide

## Executive Summary

VitalDecode is a native iOS blood test decoder app that transforms complex lab results into plain-English insights. Targeting the US health-conscious market, it combines VisionKit document scanning, Vision OCR, and optional AI analysis (OpenAI GPT-4o-mini) to deliver a 3-step experience: Scan, Decode, Optimize.

**Key Differentiators:**
- Dual-range comparison: Standard reference vs. Optimal range reveals "normal but not optimal" blind spots
- Biomarker correlation analysis: Connects related markers (e.g., Ferritin + CRP) for deeper insights
- Privacy-first: Local OCR + local SwiftData storage; AI analysis is optional
- Native iOS only: VisionKit + Vision + Swift Charts + SwiftData — no web wrappers
- 100+ biomarkers covered across CBC, Metabolic, Lipid, Thyroid, Hormones, Vitamins, Iron, Liver, Kidney, Inflammation

**Target Audience:** Health optimizers (25-45), chronic condition patients (40-65), health-anxious users (25-40), caregivers (30-55), medical professionals

**Target Market:** United States

**Minimum iOS:** 17.0

## Competitive Analysis

| App | Platform | Pricing | Strengths | Weaknesses | Our Advantage |
|-----|----------|---------|-----------|------------|---------------|
| Bloodwork.app | Web | $199/test | Optimal range analysis | No iOS app, extremely expensive | Native iOS + subscription at 1/40 price |
| MedInsight: Lab Results AI | iOS | Free + IAP | AI analysis, PDF/image upload | Limited trend tracking, no optimal ranges | Dual-range + trend charts + HealthKit |
| BloodGPT | Web | $9.99/mo | AI interpretations, HIPAA compliant | No native iOS app, web-only | Native iOS + offline OCR + Swift Charts |
| Blood Buddy | iOS/Web | $9.99/mo | AI-powered insights, progress tracking | No optimal range comparison | Dual-range system + biomarker correlation |
| Kantesti | Web | Free/paid | 98.7% accuracy claim | No app, web-only experience | Native app + offline OCR + subscription value |
| InsideTracker | Web | $179+/test | Professional biomarker analysis | Requires their blood test kit, expensive | Upload any lab report + 1/6 price |
| Blody (AI Blood Test) | iOS | Free + IAP | On App Store | Manual input focus, weak OCR | Strong OCR + auto-parsing + trends |
| Wizey | iOS | Subscription | Feature-rich | Complex UI, steep learning curve | Minimalist design + 1-step scan |
| Healtix | iOS | Subscription | Comprehensive | Bloated features, complex UI | Blood-test focused + clean UI |

## Apple Design Guidelines Compliance

- **HealthKit HIG**: Request health data access only when contextually relevant; provide clear justification messages in the system permission dialog; never replicate the system permission screen
- **Privacy Protection**: All health data stored locally via SwiftData; AI analysis is optional and user-controlled; no data leaves the device without explicit user action; privacy policy URL required for App Store submission
- **Medical App Guidelines**: App includes disclaimer that it does not provide medical advice, diagnosis, or treatment; no use of "Doctor" or "Diagnosis" in branding to avoid FDA scrutiny; informational purposes only
- **Accessibility**: VoiceOver support for all biomarker data; Dynamic Type compatibility; high-contrast color system for status indicators; minimum touch target 44pt
- **Works with Apple Health Badge**: Use official badge only if HealthKit integration is active; follow Apple's badge usage guidelines exactly
- **App Store Review 1.4.1**: Health/fitness apps must clearly disclose data practices; must include privacy policy; must not make false medical claims

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (VisionKit bridge only)
- **Data**: SwiftData (iOS 17+), no Core Data
- **OCR**: Vision Framework (VNRecognizeTextRequest), VisionKit (VNDocumentCameraViewController), PDFKit
- **Charts**: Swift Charts (native)
- **AI**: OpenAI API (GPT-4o-mini) — optional, user-provided API key or subscription
- **Health**: HealthKit (optional read/write for lab results)
- **Payments**: StoreKit 2 (subscriptions + non-consumable)
- **Concurrency**: async/await + actor, no Combine
- **Error Handling**: Custom Error enums + typed throws
- **Dependencies**: SPM only, minimal third-party (IRLPDFScanContent for VisionKit SwiftUI wrapper)

## Module Structure

```
VitalDecode/
├── App/
│   ├── VitalDecodeApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── BloodTestReport.swift
│   ├── Biomarker.swift
│   ├── BiomarkerDefinitions.swift
│   └── UserProfile.swift
├── Services/
│   ├── OCRService.swift
│   ├── BiomarkerParser.swift
│   ├── AIAnalysisService.swift
│   ├── HealthKitManager.swift
│   ├── StoreManager.swift
│   └── ExportService.swift
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Scan/
│   │   ├── ScanView.swift
│   │   ├── ScanViewModel.swift
│   │   └── DocumentScannerView.swift
│   ├── Results/
│   │   ├── ResultsView.swift
│   │   ├── ResultsViewModel.swift
│   │   ├── BiomarkerRowView.swift
│   │   └── HealthScoreView.swift
│   ├── Trends/
│   │   ├── TrendsView.swift
│   │   ├── TrendsViewModel.swift
│   │   └── BiomarkerChartView.swift
│   ├── Insights/
│   │   ├── InsightsView.swift
│   │   └── InsightsViewModel.swift
│   ├── Paywall/
│   │   ├── PaywallView.swift
│   │   └── PaywallViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Shared/
│       ├── StatusBadge.swift
│       ├── RangeBarView.swift
│       └── CategoryHeader.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── NotificationNames.swift
└── Resources/
    └── Assets.xcassets/
```

## Implementation Flow

1. **Project Setup**: Configure Xcode project with iOS 17.0 deployment target, SwiftData, HealthKit capability, Camera usage description
2. **Data Models**: Implement BloodTestReport and Biomarker SwiftData models with all relationships and enums
3. **Biomarker Definitions**: Create comprehensive biomarker dictionary with 100+ markers including reference ranges, optimal ranges, units, and categories
4. **OCR Service**: Implement VisionKit document scanner + Vision OCR text recognition + PDFKit text extraction
5. **Biomarker Parser**: Build regex-based parser to extract biomarker name, value, unit, and reference range from OCR text
6. **Scan Flow**: Create ScanView with camera/PDF/manual input options; implement scan confirmation UI
7. **Results Display**: Build ResultsView with health score, dual-range comparison, color-coded status, and category grouping
8. **Trend Tracking**: Implement TrendsView with Swift Charts for multi-time-dimension biomarker trends
9. **AI Analysis**: Integrate OpenAI API for plain-English interpretation, correlation analysis, and actionable recommendations
10. **StoreKit 2**: Implement subscription management with monthly, annual, and lifetime options; create PaywallView
11. **HealthKit Integration**: Add optional HealthKit read/write for lab result data
12. **Settings & Support**: Build SettingsView with profile management, iCloud sync toggle, policy links, and contact support
13. **Onboarding**: Create 3-screen onboarding flow for first-time users
14. **Export**: Implement PDF export for reports and CSV export for biomarker data

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: Teal #00B4D8 (health/trust/professional)
  - Background: White #FFFFFF
  - Secondary Background: Light Gray #F8F9FA
  - Optimal: Green #34C759
  - Normal: Blue #007AFF
  - Slightly Off: Orange #FF9500
  - Critical: Red #FF3B30
  - Primary Text: Dark Gray #1C1C1E
  - Secondary Text: Medium Gray #8E8E93

- **Typography**: SF Pro system font; title .largeTitle, section header .title3, body .body, caption .caption

- **Layout**:
  - Tab-based navigation: Scan, Results, Trends, Insights, Profile
  - Card-based biomarker display with rounded corners (12pt radius)
  - Max content width 720pt for iPad with `.frame(maxWidth: 720).frame(maxWidth: .infinity)`
  - 16pt horizontal padding, 12pt vertical spacing between cards
  - No `.tabViewStyle(.sidebarAdaptable)` — use default tab style

- **Animations**: Subtle spring animations for card transitions; progress bar animations for health score; chart entry animations

- **Status Color System**:
  - Critical High/Low: Red background + warning icon + "Needs Attention"
  - High/Low: Orange background + lightning icon + "Slightly Off"
  - Normal: Blue background + checkmark icon + "In Standard Range"
  - Optimal: Green background + star icon + "At Best Level"

## Code Generation Rules

- Architecture: MVVM + Repository Pattern
- Concurrency: async/await + actor, no Combine
- Data: SwiftData (iOS 17+), no Core Data
- UI: SwiftUI only, no UIKit except VisionKit bridge
- Min deployment: iOS 17.0
- Swift version: 5.9+
- Error handling: Custom Error enums + typed throws
- Naming: PascalCase types, camelCase properties/methods
- Dependencies: SPM only, minimize third-party
- No comments in code unless explicitly asked
- All SwiftData attributes must be optional or have default values
- All relationships must have inverse relationships
- iPad: Always add `.frame(maxWidth: 720).frame(maxWidth: .infinity)` for main content in ScrollView
- Never use `.tabViewStyle(.sidebarAdaptable)`

## Build & Deployment Checklist

- [ ] Xcode project configured with iOS 17.0 deployment target
- [ ] Bundle ID set to com.zzoutuo.VitalDecode
- [ ] HealthKit capability enabled with required permissions
- [ ] Camera usage description added to Info.plist
- [ ] App icon generated and added to Asset Catalog
- [ ] StoreKit 2 subscription products configured
- [ ] Privacy Policy page deployed to GitHub Pages
- [ ] Support page deployed to GitHub Pages
- [ ] Terms of Use page deployed (subscription required)
- [ ] App Store metadata prepared (keytext.md)
- [ ] Screenshots captured for iPhone and iPad
- [ ] TestFlight beta testing completed
- [ ] App Store review submitted
