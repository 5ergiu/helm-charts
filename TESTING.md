# Helm Charts Testing Guide

This repository includes comprehensive tests for all Helm charts to validate common parameters and configuration.

## Prerequisites

You need to have the following tools installed:

- **Helm 3.8+**
- **kubectl** (Kubernetes CLI)
- **kind** (Kubernetes in Docker, for integration testing)
- **helm-unittest plugin**

### Installing helm-unittest

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest
```

## Running Tests

### Run All Chart Tests

Use the provided test runner script to run tests for all charts:

```bash
./scripts/test.sh
```

This script will:
- Check if all prerequisites are installed
- Update dependencies for each chart
- Run linting
- Run unit tests
- Run template rendering validation
- (Optional) Run integration tests in a Kind cluster

### Run Tests for Individual Charts

You can also run tests for individual charts:

```bash
# Test specific chart
./scripts/test.sh laravel

# Test without creating Kind cluster (unit tests only)
./scripts/test.sh laravel --no-kind

# Keep cluster running after tests
./scripts/test.sh laravel --no-cleanup
```

### Manual Testing

#### Update Dependencies

```bash
# Update dependencies first
helm dependency update charts/laravel
```

#### Run Unit Tests

```bash
# Run unit tests
helm unittest charts/laravel
```

#### Lint Chart

```bash
# Lint the chart
helm lint charts/laravel
```

#### Template Rendering

```bash
# Test template rendering
helm template my-release charts/laravel --debug
```

## Writing Tests

Tests are located in the `tests/` directory within each chart. We use the [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin.

### Test File Structure

```yaml
suite: test my feature
templates:
  - deployment.yaml
tests:
  - it: should create a deployment
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: RELEASE-NAME-laravel
```

### Common Test Patterns

#### Testing Values

```yaml
- it: should use custom image
  set:
    image.repository: custom/image
    image.tag: custom-tag
  asserts:
    - equal:
        path: spec.template.spec.containers[0].image
        value: custom/image:custom-tag
```

#### Testing Conditions

```yaml
- it: should enable ingress when enabled
  set:
    ingress.enabled: true
  asserts:
    - isKind:
        of: Ingress
```

#### Testing Security Contexts

```yaml
- it: should run as non-root
  asserts:
    - equal:
        path: spec.template.spec.securityContext.runAsNonRoot
        value: true
```

## CI/CD Integration

Tests are automatically run on:
- Pull requests
- Pushes to main branch
- Manual workflow dispatch

See `.github/workflows/` for workflow configurations.

## Troubleshooting

### helm-unittest not found

Install the plugin:
```bash
helm plugin install https://github.com/helm-unittest/helm-unittest
```

### Kind cluster issues

Delete and recreate:
```bash
kind delete cluster --name helm-chart-test
./scripts/test.sh --create-cluster
```

### Test failures

Run tests in verbose mode:
```bash
helm unittest --debug charts/laravel
```

## Best Practices

1. **Test all templates** - Every template should have corresponding tests
2. **Test default values** - Ensure defaults work correctly
3. **Test edge cases** - Test with various value combinations
4. **Test security** - Verify security contexts, read-only filesystems, etc.
5. **Keep tests maintainable** - Use clear descriptions and organize tests logically

## Resources

- [helm-unittest Documentation](https://github.com/helm-unittest/helm-unittest)
- [Helm Testing Best Practices](https://helm.sh/docs/topics/chart_tests/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
