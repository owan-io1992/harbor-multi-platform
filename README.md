# Harbor Multi-Platform

This project provides multi-platform container images for Harbor.

## How to Use

### Docker Compose (via Installer)

If you install Harbor using the official [installer](https://goharbor.io/docs/2.14.0/install-config/download-installer/):

1.  After running the `install.sh` script, you need to modify the generated `docker-compose.yml` file to use the multi-platform images.

2.  Run the following command to replace the default images with the multi-platform ones:

```bash
sed -i 's|image: goharbor/|image: ghcr.io/owan-io1992/harbor-multi-platform/|g' docker-compose.yml
```

3.  Start Harbor using Docker Compose:

```bash
sudo docker compose up -d
```

### Helm Chart

1.  Create a YAML file named `harbor-multi-platform.yaml` with the following content to override the default image repositories:

```yaml
# harbor-multi-platform.yaml
nginx:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/nginx-photon

portal:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-portal

core:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-core

jobservice:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-jobservice

registry:
  registry:
    image:
      repository: ghcr.io/owan-io1992/harbor-multi-platform/registry-photon
  controller:
    image:
      repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-registryctl

trivy:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/trivy-adapter-photon

database:
  internal:
    image:
      repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-db

redis:
  internal:
    image:
      repository: ghcr.io/owan-io1992/harbor-multi-platform/redis-photon

exporter:
  image:
    repository: ghcr.io/owan-io1992/harbor-multi-platform/harbor-exporter
```

2.  Add the Harbor Helm repository and install the chart with your custom values:

```bash
helm repo add harbor https://helm.goharbor.io
helm upgrade --install my-harbor harbor/harbor -f harbor-multi-platform.yaml
```

## Why not use `docker buildx`?

The current Harbor build process is complex and involves multiple Dockerfiles. Additionally, some necessary data is not copied into the image during the build phase. These factors make it difficult to directly build multi-platform images using `docker buildx`. This project works around those limitations to provide pre-built multi-platform images.
