# Pin Flutter so local containers, CI, and release builds use the same toolchain.
FROM debian:bookworm-slim AS flutter-build
ARG FLUTTER_VERSION=3.50.1
ARG API_BASE_URL=/api/v1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils zip libglu1-mesa && rm -rf /var/lib/apt/lists/*
RUN curl --fail --silent --show-error --location "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux-${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ -C /opt
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
WORKDIR /workspace
COPY pubspec.yaml pubspec.lock ./
RUN flutter config --no-analytics && flutter pub get
COPY . .
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.29-alpine AS web-runtime
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=flutter-build /workspace/build/web /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=20s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
