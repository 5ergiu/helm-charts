## 📝 Description

<!-- Provide a clear and concise description of the changes -->

## 🎯 Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🧪 Test update
- [ ] 🔧 Configuration/infrastructure change

## 📦 Affected Chart(s)

<!-- List the charts affected by this PR -->

- [ ] Laravel
- [ ] Next.js
- [ ] Other: _________

## 🔗 Related Issues

<!-- Link any related issues here -->

Closes #
Related to #

## 🧪 Testing

<!-- Describe the tests you ran to verify your changes -->

### Local Testing

- [ ] Passed `helm lint`
- [ ] Passed `helm unittest`
- [ ] Tested template rendering with `helm template`
- [ ] Manually tested installation in local cluster

### Test Commands

```bash
# Commands used for testing
./scripts/test.sh chart-name
```

## 📸 Screenshots/Output

<!-- If applicable, add screenshots or command output to help explain your changes -->

<details>
<summary>Test Output</summary>

```
Paste test output here
```

</details>

## ✅ Checklist

<!-- Mark completed items with an 'x' -->

- [ ] I have read the [CONTRIBUTING.md](../CONTRIBUTING.md) guidelines
- [ ] Chart version has been bumped following [semantic versioning](https://semver.org/)
- [ ] Changes follow the commit message convention (`feat(chart):`, `fix(chart):`, etc.)
- [ ] All tests pass locally (`./scripts/test.sh`)
- [ ] Documentation has been updated (README.md, values.yaml comments)
- [ ] CHANGELOG entry will be generated automatically after merge
- [ ] Breaking changes are clearly documented (if applicable)

## 📋 Additional Context

<!-- Add any other context about the pull request here -->

## 🔄 Migration Guide

<!-- If this is a breaking change, provide a migration guide for users -->

**Before:**
```yaml
# Old configuration
```

**After:**
```yaml
# New configuration
```

---

**Reviewer Notes:**
<!-- @maintainers - Add any specific points you'd like reviewers to focus on -->
