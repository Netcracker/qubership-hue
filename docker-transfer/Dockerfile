FROM python:3.12-slim AS builder

WORKDIR /app

COPY docker-transfer/sync.py /app/sync.py
COPY chart /app/chart
COPY docs /app/docs

COPY docker-transfer/validation.py /app/validation.py
COPY hue_docker/Dockerfile /app/hue_docker_Dockerfile

RUN pip install --no-cache-dir ruamel.yaml pyyaml && \
    python validation.py chart/helm/hue/values.yaml chart/helm/hue/values.schema.json && \
    python sync.py chart/helm/hue/release-images.yaml chart/helm/hue/values.yaml && \
    TAG=$(grep -oP 'FROM gethue/hue:\K[^\s]+' /app/hue_docker_Dockerfile) && \
    printf 'version: "%s"\n' "$TAG" > /app/community-tag.yaml

FROM scratch

COPY --from=builder /app/chart /chart
COPY --from=builder /app/docs /docs
COPY --from=builder /app/community-tag.yaml /community-tag.yaml
