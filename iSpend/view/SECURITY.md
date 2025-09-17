# Security Policy for iSpend

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in iSpend, please report it by emailing spencer@example.com or by creating a private security advisory on GitHub.

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes

## Security Measures

This project implements:
- Input sanitization and validation
- Secure data storage with SwiftData
- Regular dependency updates
- Automated security scanning via GitHub Actions

## Dependencies Security

We regularly update our dependencies to address known vulnerabilities:
- REXML >= 3.2.8 (fixes ReDoS vulnerability)
- Fastlane >= 2.217.0
- All iOS framework dependencies are kept up-to-date

## Response Timeline

- Initial response: Within 24 hours
- Vulnerability assessment: Within 7 days  
- Fix deployment: Within 30 days (depending on severity)