FROM rust:1.99.1-bookworm AS build
RUN apt-get update && apt-get install -y --no-install-recommends g++ git python3 && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY . .
RUN python3 scripts/build-linux.py --fetch --threads 2 --output /runtime

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/luau-decompiler
COPY --from=build /runtime/ /opt/luau-decompiler/
COPY --chmod=755 deployment/entrypoint.sh deployment/health.sh /opt/luau-decompiler/
USER 65532:65532
EXPOSE 7879
STOPSIGNAL SIGTERM
HEALTHCHECK --interval=15s --timeout=4s --start-period=30s CMD ["/opt/luau-decompiler/health.sh"]
ENTRYPOINT ["/opt/luau-decompiler/entrypoint.sh"]
CMD ["/opt/luau-decompiler/bin/luau-decompile", "serve", "--listen", "0.0.0.0:7879", "--allow-remote", "--workers", "4", "--cpu-threads", "4", "--queue", "16", "--memory-mib", "1024", "--timeout-ms", "30000"]
