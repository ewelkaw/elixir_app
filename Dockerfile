# Two-stage Dockerfile.
# Stage 1 ("builder") compiles deps + app. Stage 2 ships a slim image with
# just the compiled release. Multi-stage builds keep the final image small.

# --- Stage 1: build -----------------------------------------------------------
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bullseye-20240612 AS builder

ENV MIX_ENV=prod \
    LANG=C.UTF-8

WORKDIR /app

# Install hex (package manager — pip's analogue) and rebar (Erlang build tool).
RUN mix local.hex --force && mix local.rebar --force

# Copy only mix files first to leverage Docker layer caching: as long as
# dependencies don't change, this layer is reused.
COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy the rest of the source.
COPY priv ./priv
COPY lib ./lib
COPY assets ./assets

# Build assets (Tailwind CSS + esbuild JS) and digest static files.
RUN mix assets.deploy

# Compile and assemble an OTP release — a self-contained tarball with the
# BEAM VM + your app. Conceptually similar to PyInstaller, but it's the
# blessed Erlang way to ship production apps.
RUN mix compile
RUN mix release

# --- Stage 2: runtime ---------------------------------------------------------
FROM debian:bullseye-20240612-slim AS runtime

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends libstdc++6 openssl libncurses5 locales ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PHX_SERVER=true

WORKDIR /app
RUN useradd --create-home --shell /bin/bash app
USER app

# Copy the release built in stage 1.
COPY --from=builder --chown=app:app /app/_build/prod/rel/kanban ./

EXPOSE 4000

CMD ["bin/kanban", "start"]
