# Cloudflare Dynamic DNS

This module creates a crobjob which updates Cloudflare's DNS records.

## Docker

This module expects that the Docker image is pushed to Github's Container Registry.

If this hasn't been done yet, login to GHCR and then run the following steps:

```
docker build -t ghcr.io/inssein/mainframe/cloudflare-ddns:latest .
docker push ghcr.io/inssein/mainframe/cloudflare-ddns:latest
```

If the Dockerfile ends up changing a lot, consider creating a workflow that publishes the docker image.
