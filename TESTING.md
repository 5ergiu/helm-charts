# 🧪 Testing Guide

This repository includes comprehensive tests for all Helm charts, covering linting, unit tests, template rendering, and integration tests in Kubernetes clusters.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Test Script Usage](#test-script-usage)
- [Test Types](#test-types)
- [Writing Tests](#writing-tests)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## ✅ Prerequisites

### Required Tools

- **[Helm](https://helm.sh/docs/intro/install/)** 3.8+
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)** - Kubernetes CLI
- **[Docker](https://docs.docker.com/get-docker/)** - For running Kind clusters
- **[Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)** - Kubernetes in Docker (for integration tests)

### Optional Tools

- **[chart-testing (ct)](https://github.com/helm/chart-testing)** - Enhanced chart linting
- **[helm-unittest](https://github.com/helm-unittest/helm-unittest)** - Auto-installed if needed

### Installation

#### macOS (Homebrew)

```bash
brew install helm kubectl kind docker
```

#### Linux

Follow the official installation guides for each tool linked above.

### Plugin Installation

The `helm-unittest` plugin is automatically installed when running tests. To install manually:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest
```

## 🚀 Quick Start

### Test All Charts

```bash
./scripts/test.sh
```

### Test Specific Chart

```bash
./scripts/test.sh charts/laravel
```

### Test Without Integration (Fast)

```bash
./scripts/test.sh charts/laravel --skip-integration
```

## 📖 Test Script Usage

The `./scripts/test.sh` script provides comprehensive testing with beautiful, color-coded output.

### Basic Usage

```bash
./scripts/test.sh [CHART_PATH] [OPTIONS]
```

### Examples

```bash
# Test all charts with all test types
./scripts/test.sh

# Test specific chart
./scripts/test.sh charts/laravel

# Skip linting (faster iteration during development)
./scripts/test.sh charts/laravel --skip-lint

# Skip unit tests
./scripts/test.sh charts/laravel --skip-unit

# Skip integration tests (no cluster needed)
./scripts/test.sh charts/laravel --skip-integration

# Keep cluster running for debugging
./scripts/test.sh charts/laravel --no-cleanup

# Use custom cluster name
./scripts/test.sh charts/laravel --cluster-name my-test-cluster

# Verbose output
./scripts/test.sh charts/laravel --verbose

# Get help
./scripts/test.sh --help
```

### Available Options

| Option | Description |
|--------|-------------|
| `--skip-lint` | Skip linting tests |
| `--skip-unit` | Skip unit tests |
| `--skip-integration` | Skip integration tests (no cluster needed) |
| `--no-cleanup` | Don't cleanup the Kind cluster after tests |
| `--cluster-name NAME` | Custom name for the Kind cluster (default: `helm-chart-test-<pid>`) |
| `--verbose`, `-v` | Enable verbose output |
| `--help`, `-h` | Show help message |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `CI` | Set to `true` when running in CI (auto-detected) |

### Test Clusters

**Local testing:** The test script creates an isolated Kind cluster per test run. This ensures:

- No interference with your existing Kubernetes clusters (including OrbStack)
- Clean, reproducible test environment every time
- Automatic cleanup after tests complete
- Each test run gets its own isolated cluster (using PID in cluster name)

The cluster is automatically deleted after all charts are tested, unless you use the `--no-cleanup` flag for debugging.

**CI/CD testing:** When running in CI (detected via `CI=true` environment variable), the script expects a cluster to already exist (set up by the GitHub Actions workflow). If no cluster is found, the tests will fail immediately with a clear error message.

## 🔬 Test Types

The test script runs four types of tests in sequence:

### 1. 📋 Linting (`--skip-lint` to skip)

Validates chart structure and best practices.

**What's tested:**
- Helm lint with strict mode (`helm lint --strict`)
- Chart-testing lint (if `ct` is installed)
- Chart dependencies are built automatically

**Example output:**
```
▸ Running Lint Tests
🔧 Building chart dependencies...
🔧 Running helm lint...
✅ Helm lint passed
🔧 Running chart-testing lint...
✅ Chart-testing lint passed
✅ All lint tests passed
```

### 2. 🧪 Unit Tests (`--skip-unit` to skip)

Runs Helm unittest tests defined in `tests/` directory.

**What's tested:**
- Template rendering with various value combinations
- Conditional logic
- Value validations
- Edge cases

**Features:**
- Automatically skips if no `tests/` directory exists
- Respects `.disable-unittest` flag file
- Auto-installs helm-unittest plugin if missing

**Example output:**
```
▸ Running Unit Tests
🔧 Running helm unittest...
✅ Unit tests passed
✅ All unit tests passed
```

### 3. 📝 Template Rendering

Tests template rendering and YAML validation.

**What's tested:**
- Templates render without errors
- Generated YAML is valid Kubernetes manifests
- CI values files are automatically used (from `ci/` directory)

**CI Values Files:**
The test script automatically detects and uses all `.yaml` files in the `ci/` directory of your chart. These values override the default `values.yaml` and are ideal for:
- Providing minimal test configurations
- Setting test-specific image tags (e.g., `tag: latest`)
- Enabling required features for testing
- Reducing resource requests for faster tests

Example: `charts/laravel/ci/values.test.yaml`

**Example output:**
```
▸ Testing Template Rendering
ℹ️  Found CI values files
🔧 Rendering templates...
✅ Templates rendered successfully
🔧 Validating rendered YAML...
✅ Generated YAML is valid
✅ Template rendering tests passed
```

### 4. 🐳 Integration Tests (`--skip-integration` to skip)

Full integration testing in a real Kubernetes cluster.

**What happens:**
1. Creates isolated Kind cluster (local) or uses existing cluster (CI)
2. Installs Traefik for IngressRoute support
3. Installs the chart with CI values (from `ci/` directory)
4. Waits for pods to be ready
5. Runs Helm tests (if defined)
6. Tests chart upgrade
7. Cleans up resources
8. Deletes cluster (local only, unless `--no-cleanup`)

**Note:** CI values files from `ci/` directory are automatically applied during installation, overriding default `values.yaml` settings.

**Example output:**
```
▸ Setting Up Test Cluster
🔧 Creating kind cluster: helm-chart-test-12345
✅ Kind cluster created successfully
✅ Cluster is ready

▸ Installing Traefik
🔧 Adding Traefik Helm repository...
🔧 Installing Traefik with CRD provider enabled...
✅ Traefik installed successfully

▸ Running Integration Tests
🔧 Installing chart: laravel
ℹ️  Release:   test-laravel
ℹ️  Namespace: test-laravel
ℹ️  Timeout:   600s
✅ Chart installed successfully
🔧 Verifying installation...
🔧 Waiting for pods to be ready...
✅ All pods are ready
🔧 Running Helm tests...
✅ Helm tests passed
🔧 Testing chart upgrade...
✅ Chart upgrade successful
🔧 Cleaning up test installation...
✅ All integration tests passed

▸ Cleaning Up
🔧 Deleting kind cluster: helm-chart-test-12345
✅ Cluster deleted successfully
```

### Library Charts

Library charts (with `type: library` in `Chart.yaml`) automatically skip template rendering and integration tests, running only lint and unit tests.

## ✍️ Writing Tests

Tests are written using the [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin.

### Directory Structure

```
charts/my-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── ci/                      # CI values (optional)
│   ├── default.yaml
│   └── minimal.yaml
└── tests/                   # Unit tests
    ├── deployment_test.yaml
    ├── service_test.yaml
    └── ingress_test.yaml
```

### Test File Structure

```yaml
suite: test deployment
templates:
  - deployment.yaml
tests:
  - it: should create a deployment
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: RELEASE-NAME-my-chart
```

### Common Test Patterns

#### Testing Default Values

```yaml
- it: should use default image
  asserts:
    - equal:
        path: spec.template.spec.containers[0].image
        value: my-app:latest
```

#### Testing Custom Values

```yaml
- it: should use custom image
  set:
    image.repository: custom/image
    image.tag: v2.0.0
  asserts:
    - equal:
        path: spec.template.spec.containers[0].image
        value: custom/image:v2.0.0
```

#### Testing Conditionals

```yaml
- it: should create ingress when enabled
  set:
    ingress.enabled: true
  template: ingress.yaml
  asserts:
    - isKind:
        of: Ingress

- it: should not create ingress when disabled
  set:
    ingress.enabled: false
  template: ingress.yaml
  asserts:
    - hasDocuments:
        count: 0
```

#### Testing Security Contexts

```yaml
- it: should run as non-root
  asserts:
    - equal:
        path: spec.template.spec.securityContext.runAsNonRoot
        value: true
    - equal:
        path: spec.template.spec.securityContext.runAsUser
        value: 1000
```

#### Testing Resources

```yaml
- it: should set resource limits
  set:
    resources.limits.cpu: "1000m"
    resources.limits.memory: "1Gi"
  asserts:
    - equal:
        path: spec.template.spec.containers[0].resources.limits.cpu
        value: "1000m"
    - equal:
        path: spec.template.spec.containers[0].resources.limits.memory
        value: "1Gi"
```

#### Testing Lists

```yaml
- it: should have correct environment variables
  set:
    env:
      - name: APP_ENV
        value: production
  asserts:
    - contains:
        path: spec.template.spec.containers[0].env
        content:
          name: APP_ENV
          value: production
```

### Disabling Unit Tests

If a chart doesn't need unit tests (rare), create a `.disable-unittest` file:

```bash
touch charts/my-chart/.disable-unittest
```

## 🔄 CI/CD Integration

Tests run automatically in GitHub Actions:

### Pull Requests

All charts are tested when:
- New PRs are opened
- PRs are updated
- Changes affect chart files

### Releases

Charts are tested before:
- Building chart artifacts
- Publishing to OCI registry
- Creating GitHub releases

### Workflow Structure

1. **Changed Charts Detection**: Identifies which charts changed
2. **Chart Resolution**: Determines which charts to test
3. **Cluster Setup**: Creates one Kind cluster for the entire test run
4. **Sequential Chart Testing**: Each chart is tested sequentially on the shared cluster
   - Lint tests
   - Unit tests
   - Template rendering
   - Integration tests (using the shared cluster)

## 🔧 Troubleshooting

### Manual Cleanup Required

If the test script fails to automatically delete the cluster, you'll see a message with manual cleanup instructions:

```bash
# List all Kind clusters
kind get clusters

# Delete specific cluster (use the cluster name from the error message)
kind delete cluster --name helm-chart-test-<pid>
```

**Note:** Each test run creates a unique cluster name using the process ID, so there's no risk of conflicts with existing clusters.

### Tests Failing

Keep the cluster running to investigate:

```bash
# Run tests without cleanup
./scripts/test.sh charts/laravel --no-cleanup

# Check cluster state
kubectl get all -A

# View pod logs
kubectl logs -n test-laravel -l app.kubernetes.io/name=laravel

# Check events
kubectl get events -n test-laravel --sort-by='.lastTimestamp'

# When done investigating
kind delete cluster --name helm-chart-test-<pid>
```

### Plugin Not Found

Install the helm-unittest plugin:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest
```

### Template Rendering Errors

Debug template rendering:

```bash
# Test template rendering manually
helm template test charts/my-chart --debug

# Test with specific values
helm template test charts/my-chart -f test-values.yaml --debug
```

### Integration Test Timeouts

Increase timeout in the test script or check pod status:

```bash
# Check why pods aren't ready
kubectl describe pods -n test-my-chart

# Check logs
kubectl logs -n test-my-chart -l app.kubernetes.io/name=my-chart
```

## 💡 Best Practices

### Test Coverage

1. **Test all templates** - Every template should have corresponding tests
2. **Test default values** - Ensure defaults work correctly
3. **Test common scenarios** - Cover typical use cases
4. **Test edge cases** - Unusual value combinations
5. **Test security** - Verify security contexts, non-root users, read-only filesystems

### Test Organization

```
tests/
├── deployment_test.yaml     # Deployment-specific tests
├── service_test.yaml        # Service-specific tests
├── ingress_test.yaml        # Ingress-specific tests
├── configmap_test.yaml      # ConfigMap tests
└── security_test.yaml       # Security-focused tests
```

### Naming Conventions

- Use descriptive test names: `should create ingress when enabled`
- Group related tests in the same file
- Use consistent formatting

### CI Values

Create multiple CI value files for different scenarios:

```
ci/
├── default.yaml          # Minimal working configuration
├── full-features.yaml    # All features enabled
├── high-availability.yaml # HA configuration
└── security-hardened.yaml # Security-focused config
```

### Performance

- Use `--skip-integration` during rapid development
- Use `--skip-lint` if only testing logic changes
- Run full tests before committing

## 📚 Resources

- [helm-unittest Documentation](https://github.com/helm-unittest/helm-unittest)
- [Helm Testing Best Practices](https://helm.sh/docs/topics/chart_tests/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Chart Testing Tool](https://github.com/helm/chart-testing)

## 🎯 Testing Workflow

### During Development

```bash
# Quick iteration (no integration tests)
./scripts/test.sh charts/my-chart --skip-integration

# Full local test before committing
./scripts/test.sh charts/my-chart
```

### Before Pull Request

```bash
# Test all affected charts
./scripts/test.sh

# Verify CI will pass
./scripts/test.sh charts/my-chart
```

### Debugging Failures

```bash
# Keep cluster for investigation
./scripts/test.sh charts/my-chart --no-cleanup

# Run with verbose output
./scripts/test.sh charts/my-chart --verbose

# Skip passing tests to focus on failures
./scripts/test.sh charts/my-chart --skip-lint --skip-unit
```

---

**Happy Testing! 🎉**

For questions or issues, please open a GitHub issue or refer to [CONTRIBUTING.md](./CONTRIBUTING.md).
