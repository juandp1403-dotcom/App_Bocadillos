FROM debian:bookworm-slim AS build

ARG FLUTTER_VERSION=3.47.7

ENV DEBIAN_FRONTEND=noninteractive \
    FLUTTER_HOME=/opt/flutter \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH \
    CI=true \
    FLUTTER_SUPPRESS_ANALYTICS=true

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        file \
        git \
        libglu1-mesa \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch "${FLUTTER_VERSION}" \
        https://github.com/flutter/flutter.git "${FLUTTER_HOME}" \
    && flutter config --enable-web \
    && flutter precache --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=https://backendfast.softlane.click
RUN test -n "$API_BASE_URL" \
    && flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1
