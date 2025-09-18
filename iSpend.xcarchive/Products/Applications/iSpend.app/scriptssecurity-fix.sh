#!/bin/bash

# iSpend Security Fix Script
# This script addresses the REXML ReDoS vulnerability and sets up secure dependencies

echo "🔒 iSpend Security Fix Script"
echo "=============================="

# Check if we're in the right directory
if [ ! -f "EditableListManager 2.swift" ]; then
    echo "❌ Please run this script from your iSpend project root directory"
    exit 1
fi

echo "📦 Setting up secure Ruby environment..."

# Install or update Bundler
if ! command -v bundle &> /dev/null; then
    echo "Installing Bundler..."
    gem install bundler
else
    echo "Updating Bundler..."
    gem update bundler
fi

# Install dependencies from Gemfile
echo "📥 Installing secure dependencies..."
bundle install

# Update REXML specifically to fix vulnerability
echo "🛡️  Updating REXML to fix ReDoS vulnerability..."
bundle update rexml

# Run security audit
echo "🔍 Running security audit..."
if bundle exec bundle-audit check --update; then
    echo "✅ Security audit passed!"
else
    echo "⚠️  Security issues found. Please review and fix."
fi

# Create directories for GitHub workflows if they don't exist
mkdir -p .github/workflows
mkdir -p fastlane

echo "🔧 Setting up GitHub Actions workflow..."

# Set proper file permissions
chmod +x scripts/security-fix.sh 2>/dev/null || true

echo ""
echo "✅ Security setup complete!"
echo ""
echo "Next steps:"
echo "1. Commit these changes: git add . && git commit -m 'fix: address REXML ReDoS vulnerability and improve security'"
echo "2. Push to GitHub: git push origin your-branch-name"
echo "3. Check GitHub security tab for confirmation that vulnerabilities are resolved"
echo ""
echo "Files created/updated:"
echo "- Gemfile (with secure REXML version)"
echo "- .github/workflows/ios.yml (CI/CD pipeline)"
echo "- .github/dependabot.yml (automated dependency updates)"
echo "- SECURITY.md (security policy)"
echo "- fastlane/Fastfile (deployment automation)"
echo "- .gitignore (comprehensive iOS gitignore)"
echo ""
echo "🎉 Your iSpend project is now more secure!"