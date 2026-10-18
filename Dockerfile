# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: CC0-1.0
#
# Multi-stage release build. Versions follow .tool-versions.
#   docker build -t oc-core/core .
#   docker run -e DATABASE_URL=... -e SECRET_KEY_BASE=... -e PHX_HOST=... -p 4000:4000 oc-core/core

ARG ELIXIR_VERSION=1.20.4
ARG OTP_VERSION=29.0
ARG DEBIAN_VERSION=bookworm-20251006-slim
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY apps/occ_core/mix.exs apps/occ_core/mix.exs
COPY apps/occ_core_web/mix.exs apps/occ_core_web/mix.exs
COPY config/config.exs config/prod.exs config/
RUN mix deps.get --only $MIX_ENV && mix deps.compile

COPY apps apps
COPY config/runtime.exs config/
RUN mix compile && mix release occ_core

FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

WORKDIR /app
RUN chown nobody /app
ENV MIX_ENV=prod
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/occ_core ./
USER nobody
CMD ["/app/bin/server"]
