FROM python:3.12-slim AS builder

WORKDIR /app

COPY docker-transfer/sync.py /app/sync.py
COPY chart /app/chart
COPY docs /app/docs

RUN pip install --no-cache-dir ruamel.yaml && \
    python sync.py chart/helm/hue/release-images.yaml chart/helm/hue/values.yaml

FROM scratch

COPY --from=builder /app/chart /chart
COPY --from=builder /app/docs /docs
