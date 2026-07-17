# DevGuard Helm Chart Distribution

This repository includes automated workflows for distributing the DevGuard Helm chart to both GitHub and GitLab package registries.

## GitHub Actions Workflow

The GitHub Actions workflow (`.github/workflows/helm-release.yml`) automatically:

- **Triggers on**: Git tags starting with `v` (e.g., `v0.15.3`) or manual workflow dispatch
- **Packages**: The Helm chart with the specified version
- **Publishes**: To GitHub Container Registry (`ghcr.io`)
- **Creates**: GitHub releases with chart artifacts

### Usage

1. **Automatic release** (recommended):
   ```bash
   git tag v0.15.4
   git push origin v0.15.4
   ```

2. **Manual release**:
   - Go to Actions tab in GitHub
   - Select "Release Helm Chart" workflow
   - Click "Run workflow" and specify version

### Installing from GitHub Container Registry

```bash
# Add the repository
helm repo add devguard oci://ghcr.io/your-username

# Install the chart
helm install my-devguard oci://ghcr.io/your-username/devguard --version 0.15.3

# Or pull the chart
helm pull oci://ghcr.io/your-username/devguard --version 0.15.3
```

## GitLab CI Pipeline

The GitLab CI configuration (`.gitlab-ci.yml`) automatically:

- **Triggers on**: Git tags starting with `v` or manual pipeline runs
- **Lints**: Chart on merge requests and main branch
- **Packages**: The Helm chart with the specified version
- **Publishes**: To GitLab Container Registry
- **Creates**: GitLab releases (optional, requires `GITLAB_TOKEN`)

### Setup Requirements

For GitLab releases (optional), add a project access token:
1. Go to Project Settings → Access Tokens
2. Create token with `api` scope
3. Add as CI/CD variable named `GITLAB_TOKEN`

### Usage

1. **Automatic release**:
   ```bash
   git tag v0.15.4
   git push origin v0.15.4
   ```

2. **Manual release**:
   - Go to CI/CD → Pipelines
   - Click "Run pipeline"
   - The `helm-release` job can be triggered manually

### Installing from GitLab Container Registry

```bash
# Login to GitLab registry (if private)
helm registry login registry.gitlab.com --username your-username

# Install the chart
helm install my-devguard oci://registry.gitlab.com/your-group/devguard-helm-chart/devguard --version 0.15.3

# Or pull the chart
helm pull oci://registry.gitlab.com/your-group/devguard-helm-chart/devguard --version 0.15.3
```

## Version Management

Both workflows automatically:
- Extract version from Git tags (removing the `v` prefix)
- Update `Chart.yaml` with the correct version and appVersion
- Package the chart with the proper version

## Registry Permissions

### GitHub
- Uses `GITHUB_TOKEN` (automatically provided)
- Requires `packages: write` permission (included in workflow)

### GitLab
- Uses `CI_REGISTRY_USER` and `CI_REGISTRY_PASSWORD` (automatically provided)
- Works with GitLab Container Registry by default

## Chart Structure

The workflows expect the standard Helm chart structure:
```
Chart.yaml          # Chart metadata
values.yaml         # Default values
templates/          # Kubernetes templates
  _helpers.tpl      # Template helpers
  ...
```

## Troubleshooting

### Common Issues

1. **Authentication failures**: Ensure proper permissions are set for the repository
2. **Version conflicts**: Make sure tag versions match semantic versioning (e.g., `v1.2.3`)
3. **Registry limits**: Check registry storage limits if uploads fail

### Testing Locally

```bash
# Lint the chart
helm lint .

# Test template rendering
helm template test-release . --debug --dry-run

# Package locally
helm package .
```
