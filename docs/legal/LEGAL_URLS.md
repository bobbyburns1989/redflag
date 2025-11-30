# Pink Flag - Legal Document URLs

**Last Updated**: November 10, 2025

## Official Hosted Legal Documents

Pink Flag's legal documents are hosted at the following URLs for App Store submission and user access:

### Privacy Policy
- **URL**: https://customapps.us/pinkflag/privacy
- **Purpose**: App Store requirement, user transparency
- **Last Updated**: November 8, 2025
- **Format**: Web-accessible HTML page

### Terms of Service
- **URL**: https://customapps.us/pinkflag/terms
- **Purpose**: User agreement, acceptable use policy
- **Last Updated**: November 10, 2025
- **Format**: Web-accessible HTML page

---

## Usage in App

These URLs are referenced in multiple locations:

### App Store Connect
1. **App Information → Privacy Policy URL**:
   - Enter: `https://customapps.us/pinkflag/privacy`

2. **App Review Notes**:
   - Reference both URLs in submission notes

### In-App References
These URLs can be linked from:
- Settings screen → Legal & Support section
- Onboarding screen → Privacy policy link
- Sign-up screen → Terms acceptance
- About screen → Legal information

### Code Implementation
```dart
// lib/config/constants.dart or similar
class AppConstants {
  static const String privacyPolicyUrl = 'https://customapps.us/pinkflag/privacy';
  static const String termsOfServiceUrl = 'https://customapps.us/pinkflag/terms';
  static const String supportEmail = 'support@pinkflagapp.com';
}

// Usage with url_launcher
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicy() async {
  final uri = Uri.parse(AppConstants.privacyPolicyUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

---

## Hosting Details

### Domain Information
- **Hosting**: customapps.us
- **Subdirectory**: /pinkflag/
- **SSL Certificate**: HTTPS enabled
- **Accessibility**: Public, no authentication required

### Maintenance
- Keep URLs stable (do not change without app update)
- Update content as needed without breaking URLs
- Ensure 24/7 uptime (App Store requirement)
- Monitor for broken links

---

## Source Files

The content for these hosted pages comes from:
- **Privacy Policy**: `/PRIVACY_POLICY.md`
- **Terms of Service**: `/safety_app/assets/legal/terms_of_service.txt`

When updating legal documents:
1. Update source files in repository
2. Convert to HTML format
3. Upload to hosting server
4. Verify URLs are accessible
5. Update "Last Updated" dates

---

## Verification Checklist

Before App Store submission, verify:
- [ ] https://customapps.us/pinkflag/privacy loads correctly
- [ ] https://customapps.us/pinkflag/terms loads correctly
- [ ] Both pages display properly on mobile devices
- [ ] SSL certificate is valid (HTTPS)
- [ ] Content matches latest source files
- [ ] "Last Updated" dates are current
- [ ] No broken links within documents
- [ ] Pages load in <3 seconds

---

## App Store Requirements

Apple requires:
1. **Privacy Policy**: Public URL accessible without authentication
2. **Accessible Format**: Must work on mobile browsers
3. **Always Available**: No 404 errors or downtime
4. **Accurate Content**: Must match app's actual privacy practices

---

## Contact Information

For questions about legal documents:
- **Email**: support@pinkflagapp.com
- **Privacy Concerns**: privacy@pinkflagapp.com

---

## Version History

- **v1.0** (November 10, 2025) - Initial documentation of legal URLs
  - Privacy Policy: https://customapps.us/pinkflag/privacy
  - Terms of Service: https://customapps.us/pinkflag/terms
