# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: VitalDecode Pro
- **Group ID**: VitalDecode_Pro

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.VitalDecode.proMonthly`
- **Price**: $4.99 per month
- **Display Name**: VitalDecode Pro Monthly
- **Description**: Unlimited scans and AI insights
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.VitalDecode.proAnnual`
- **Price**: $29.99 per year (50% savings vs monthly)
- **Display Name**: VitalDecode Pro Yearly
- **Description**: Best value: full access all year
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.VitalDecode.lifetime`
- **Price**: $79.99 one-time
- **Display Name**: VitalDecode Lifetime
- **Description**: Pay once, use forever
- **Localization**: English (US)

## Free Tier

| Feature | Free Limit | Purpose |
|---------|-----------|---------|
| Scans | 1 per month | Experience core value |
| Results View | Full access | Build trust |
| Standard Range | Available | Basic value |
| Optimal Range | Locked | Core differentiator |
| AI Insights | Locked | Main conversion driver |
| Trend Tracking | 1 biomarker only | Show capability |
| HealthKit | Locked | Advanced feature |
| PDF Export | Locked | Practical feature |
| Multi-Profile | Locked | Caregiver need |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented

## StoreKit Configuration File
- File: `VitalDecode.storekit`
- Products configured matching Product IDs above
