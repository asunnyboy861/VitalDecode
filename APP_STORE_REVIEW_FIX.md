# App Store Review Fix Guide

## Issue Summary

### Guideline 2.1(a) - Bug Fix
**Problem**: "Analyze My Results" button was unresponsive after subscribing to Pro plan.

**Root Cause**: 
- PaywallView dismissed without properly notifying parent view
- Subscription status was not refreshed when paywall closed
- InsightsView did not detect subscription state changes

**Fix Applied**:
1. Added `onDismiss` callback to PaywallView sheet in InsightsView
2. Added `refreshSubscriptionStatus()` method to StoreManager
3. PaywallView now calls `refreshSubscriptionStatus()` after successful purchase
4. InsightsView auto-runs analysis when user becomes Pro after paywall dismisses

### Guideline 2.1(b) - IAP Submission
**Problem**: Monthly and Yearly Pro plans not submitted for review.

**Solution**: Follow steps below to submit IAP products in App Store Connect.

---

## App Store Connect IAP Setup Steps

### Step 1: Create Subscription Group

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to "My Apps" → Select "VitalDecode"
3. Navigate to "Subscriptions" in the left sidebar
4. Click "Create Subscription Group"
5. Enter:
   - **Reference Name**: `VitalDecode Pro`
   - **Group ID**: `VitalDecode_Pro`

### Step 2: Create Monthly Subscription

1. In the subscription group, click "Create Subscription"
2. Enter:
   - **Reference Name**: `Monthly Premium`
   - **Product ID**: `com.zzoutuo.VitalDecode.proMonthly`
   - **Subscription Level**: Level 1
3. Add Localization:
   - **Display Name**: `VitalDecode Pro Monthly`
   - **Description**: `Unlimited scans and AI insights`
4. Set Pricing:
   - **Price**: $4.99
   - **Billing Period**: 1 Month
5. Set Subscription Duration: 1 Month

### Step 3: Create Yearly Subscription

1. Click "Create Subscription"
2. Enter:
   - **Reference Name**: `Yearly Premium`
   - **Product ID**: `com.zzoutuo.VitalDecode.proAnnual`
   - **Subscription Level**: Level 1
3. Add Localization:
   - **Display Name**: `VitalDecode Pro Yearly`
   - **Description**: `Best value: full access all year`
4. Set Pricing:
   - **Price**: $29.99
   - **Billing Period**: 1 Year
5. Set Subscription Duration: 1 Year

### Step 4: Create Lifetime Purchase (Optional)

1. Go to "In-App Purchases" (not Subscriptions)
2. Click "Create In-App Purchase"
3. Enter:
   - **Reference Name**: `Lifetime Access`
   - **Product ID**: `com.zzoutuo.VitalDecode.lifetime`
   - **Type**: Non-Consumable
4. Add Localization:
   - **Display Name**: `VitalDecode Lifetime`
   - **Description**: `Pay once, use forever`
5. Set Pricing: $79.99

### Step 5: Add Review Screenshot

**CRITICAL**: Each IAP product requires a screenshot showing the purchase flow.

1. For each subscription product, click "Add Review Screenshot"
2. Upload a screenshot showing:
   - The PaywallView with subscription options
   - The selected tier highlighted
   - The "Subscribe Now" button visible
3. Screenshot requirements:
   - Format: JPG or PNG
   - Max size: 10MB
   - Must show the actual purchase UI from the app

Use the screenshot: `/screenshots/paywall_screenshot.jpg`

### Step 6: Submit for Review

1. After creating all products, click "Submit for Review" on each IAP
2. Go to "App Store" tab → "App Information"
3. Ensure "In-App Purchases" section shows all products
4. Submit a new binary (build) with the bug fixes

---

## Code Changes Summary

### Files Modified

1. **InsightsView.swift**
   - Added `onDismiss` callback to refresh subscription status
   - Added auto-run analysis when user becomes Pro
   - Added `handleAnalyzeButtonTap()` method with status refresh

2. **StoreManager.swift**
   - Added `refreshSubscriptionStatus()` public method
   - Ensures subscription state is always up-to-date

3. **PaywallView.swift**
   - Added error handling with alert
   - Calls `refreshSubscriptionStatus()` after purchase
   - Added delay before dismiss to ensure state updates
   - Improved restore purchases flow

---

## Testing Checklist

Before resubmitting:

- [ ] Build app in Release mode
- [ ] Test on physical device (not simulator)
- [ ] Complete purchase flow with sandbox account
- [ ] Verify "Analyze My Results" button works after purchase
- [ ] Verify restore purchases works
- [ ] Test on both iPhone and iPad

---

## Resubmission Notes

In the "Notes for Reviewer" section in App Store Connect:

```
Fixed the reported bug where "Analyze My Results" button was unresponsive after subscribing. 

Changes made:
1. Added proper subscription status refresh when paywall closes
2. Added onDismiss callback to ensure parent view updates
3. Auto-runs analysis when user becomes Pro after purchase

All IAP products (Monthly and Yearly Pro plans) are now submitted for review with required screenshots.
```
