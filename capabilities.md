# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Camera/Photo Library: Required for document scanning (VisionKit)
- HealthKit: Optional read/write for lab result data
- In-App Purchase: Subscription model (monthly, annual, lifetime)
- iCloud/CloudKit: Optional data sync across devices
- Outgoing Network Connections: Required for AI analysis (OpenAI API)

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Camera Usage | ✅ Configured | Info.plist NSCameraUsageDescription |
| Photo Library | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| HealthKit | ✅ Configured | Xcode capability + entitlements |
| In-App Purchase | ✅ Configured | StoreKit 2 (no entitlement needed) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| iCloud/CloudKit | ⏳ Optional | 1. Enable iCloud capability in Xcode 2. Select CloudKit container 3. Deploy schema to production |
| OpenAI API Key | ⏳ User-provided | User enters their own API key in Settings, or uses subscription |

## No Configuration Needed
- Push Notifications: Not required
- Location Services: Not required
- Siri: Not required
- Background Modes: Not required
- Apple Watch: Not required

## Info.plist Keys Required

| Key | Value |
|-----|-------|
| NSCameraUsageDescription | "VitalDecode needs camera access to scan your blood test reports." |
| NSPhotoLibraryUsageDescription | "VitalDecode needs photo library access to upload PDF blood test reports." |
| NSHealthShareUsageDescription | "VitalDecode reads lab result data from Health to provide analysis." |
| NSHealthUpdateUsageDescription | "VitalDecode saves analyzed lab results to Health for tracking." |

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
