# 🔐 Cosign Signature Verification

All charts in this repository can be cryptographically signed using [Cosign](https://docs.sigstore.dev/cosign/) to ensure authenticity, integrity, and supply chain security.

## 📋 Overview

Every chart published can be signed with a private key and verified using the corresponding public key. This ensures:

- **Authenticity**: Confirms charts are published by the maintainers
- **Integrity**: Ensures charts haven't been tampered with since signing
- **Supply Chain Security**: Provides end-to-end verification of chart origins

## 🔑 Public Key

All charts should be signed with the key stored in this repository.

**Public Key Location:** `cosign.pub`

To verify charts, download the public key:

```bash
curl -o cosign.pub https://raw.githubusercontent.com/5ergiu/helm-charts/main/cosign.pub
```

## ✅ Verification

### Prerequisites

Install Cosign on your system:

```bash
# macOS (using Homebrew)
brew install cosign

# Linux (using curl)
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# Windows (using winget)
winget install sigstore.cosign
```

### Verify Chart Signatures

#### For OCI Registry

```bash
# Download public key
curl -o cosign.pub https://raw.githubusercontent.com/5ergiu/helm-charts/main/cosign.pub

# Verify chart
cosign verify --key cosign.pub oci://ghcr.io/5ergiu/helm-charts/my-chart:0.1.0
```

#### For Local Chart Files

```bash
# Verify packaged chart
cosign verify-blob --key cosign.pub --signature my-chart-1.0.0.tgz.sig my-chart-1.0.0.tgz
```

### Successful Verification Output

```
Verification for ghcr.io/5ergiu/helm-charts/my-chart:0.1.0 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
```

## 🚀 Helm Integration

### Verify Before Installing

Always verify chart signatures before installation:

```bash
# 1. Verify the signature
cosign verify --key cosign.pub oci://ghcr.io/5ergiu/helm-charts/my-chart:0.1.0

# 2. Only install after successful verification
helm install my-release oci://ghcr.io/5ergiu/helm-charts/my-chart --version 0.1.0
```

## 🛡️ Security Best Practices

1. **Always verify signatures** before installing charts in production
2. **Store private keys securely** using secrets management tools
3. **Rotate keys periodically** and communicate changes to users
4. **Use different keys** for different environments if needed
5. **Monitor transparency logs** for unexpected signatures

## 🔧 Troubleshooting

### Verification Failed

If verification fails:
1. Ensure you're using the correct public key
2. Check that the chart version matches
3. Verify the registry URL is correct
4. Ensure the chart hasn't been modified

### Key Not Found

If the public key is missing:
```bash
# Download from repository
curl -o cosign.pub https://raw.githubusercontent.com/5ergiu/helm-charts/main/cosign.pub
```

## 📚 Additional Resources

- [Sigstore Documentation](https://docs.sigstore.dev/)
- [Cosign Installation Guide](https://docs.sigstore.dev/cosign/installation)
- [Supply Chain Security Best Practices](https://slsa.dev/)
- [Helm OCI Support](https://helm.sh/docs/topics/registries/)
