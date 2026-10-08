# Harbor Multi-Platform Container Images (ARM64 & AMD64)

[![Build and Merge Harbor Images](https://github.com/owan-io1992/harbor-multi-platform/actions/workflows/build-and-merge.yml/badge.svg)](https://github.com/owan-io1992/harbor-multi-platform/actions/workflows/build-and-merge.yml)
[![GitHub Release](https://img.shields.io/github/v/release/owan-io1992/harbor-multi-platform)](https://github.com/owan-io1992/harbor-multi-platform/releases)
[![Platform](https://img.shields.io/badge/platform-linux%2Farm64%20%7C%20linux%2Famd64-blue)](https://github.com/owan-io1992/harbor-multi-platform)

Pre-built multi-platform container images for [Project Harbor](https://goharbor.io/) supporting both **ARM64 (aarch64 / Apple Silicon / AWS Graviton / Raspberry Pi)** and **AMD64 (x86_64)** architectures.

Images are published to both **GitHub Container Registry (GHCR)** and **Docker Hub**.

## Images

| Image | Docker Hub | GitHub Container Registry | Note |
| :--- | :--- | :--- | :--- |
| nginx-photon | [owanio1992/nginx-photon](https://hub.docker.com/repository/docker/owanio1992/nginx-photon) | [ghcr.io/owan-io1992/harbor-multi-platform/nginx-photon](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fnginx-photon) | Reverse proxy |
| harbor-portal | [owanio1992/harbor-portal](https://hub.docker.com/repository/docker/owanio1992/harbor-portal) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-portal](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-portal) | Web UI |
| harbor-core | [owanio1992/harbor-core](https://hub.docker.com/repository/docker/owanio1992/harbor-core) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-core](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-core) | Core service |
| harbor-jobservice | [owanio1992/harbor-jobservice](https://hub.docker.com/repository/docker/owanio1992/harbor-jobservice) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-jobservice](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-jobservice) | Job service |
| registry-photon | [owanio1992/registry-photon](https://hub.docker.com/repository/docker/owanio1992/registry-photon) | [ghcr.io/owan-io1992/harbor-multi-platform/registry-photon](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fregistry-photon) | OCI Registry |
| harbor-registryctl | [owanio1992/harbor-registryctl](https://hub.docker.com/repository/docker/owanio1992/harbor-registryctl) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-registryctl](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-registryctl) | Registry controller |
| trivy-adapter-photon | [owanio1992/trivy-adapter-photon](https://hub.docker.com/repository/docker/owanio1992/trivy-adapter-photon) | [ghcr.io/owan-io1992/harbor-multi-platform/trivy-adapter-photon](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Ftrivy-adapter-photon) | Trivy scanner adapter |
| harbor-db | [owanio1992/harbor-db](https://hub.docker.com/repository/docker/owanio1992/harbor-db) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-db](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-db) | PostgreSQL database |
| redis-photon | [owanio1992/redis-photon](https://hub.docker.com/repository/docker/owanio1992/redis-photon) | [ghcr.io/owan-io1992/harbor-multi-platform/redis-photon](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fredis-photon) | Redis cache (Harbor <= v2.14) |
| valkey-photon | [owanio1992/valkey-photon](https://hub.docker.com/repository/docker/owanio1992/valkey-photon) | [ghcr.io/owan-io1992/harbor-multi-platform/valkey-photon](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fvalkey-photon) | Valkey cache (Harbor >= v2.15) |
| harbor-exporter | [owanio1992/harbor-exporter](https://hub.docker.com/repository/docker/owanio1992/harbor-exporter) | [ghcr.io/owan-io1992/harbor-multi-platform/harbor-exporter](https://github.com/owan-io1992/harbor-multi-platform/pkgs/container/harbor-multi-platform%2Fharbor-exporter) | Prometheus metrics exporter |



## Release

This project automatically checks for new releases from `goharbor/harbor` every 12 hours. If a new release is found, a corresponding multi-platform image release will be created automatically.

## Support

Currently, only releases from version 2.13 and later are supported.

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
      # For Harbor <= v2.14: redis-photon
      # For Harbor >= v2.15: valkey-photon
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
