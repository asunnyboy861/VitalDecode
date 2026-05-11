# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | VitalDecode |
| **Git URL** | git@github.com:asunnyboy861/VitalDecode.git |
| **Repo URL** | https://github.com/asunnyboy861/VitalDecode |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ENABLED (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/VitalDecode/ | ACTIVE |
| Support | https://asunnyboy861.github.io/VitalDecode/support.html | ACTIVE |
| Privacy Policy | https://asunnyboy861.github.io/VitalDecode/privacy.html | ACTIVE |
| Terms of Use | https://asunnyboy861.github.io/VitalDecode/terms.html | ACTIVE |

## Repository Structure

```
VitalDecode/
├── VitalDecode/                    # iOS App Source Code
│   ├── VitalDecode.xcodeproj/      # Xcode Project
│   ├── VitalDecode/                # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── Services/
│   │   └── ...
│   └── ...
├── docs/                           # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md                           # English development guide
├── keytext.md                      # App Store metadata
├── capabilities.md                 # App capabilities
├── icon.md                         # App icon details
├── price.md                        # Pricing configuration
├── nowgit.md                       # This file
└── screenshots/                    # App Store screenshots
    ├── 01_scan_tab.jpg
    ├── 02_results_tab.jpg
    ├── 03_trends_tab.jpg
    ├── 04_insights_tab.jpg
    └── 05_settings_tab.jpg
```

## Build & Test Status

| Test | Device | Status |
|------|--------|--------|
| Build | iPhone Xs Max | PASSED |
| Run Test | iPhone Xs Max | PASSED |
| Build | iPad Pro 13-inch (M4) | PASSED |
| Run Test | iPad Pro 13-inch (M4) | PASSED |

## Security Check

- No hardcoded API keys: PASSED
- .env in .gitignore: PASSED
- No credential URLs in code: PASSED

## Last Updated

2026-05-11
