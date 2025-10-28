# ----
# base: Minimal Python
FROM python:3.12-slim-bookworm AS base

# safety user
RUN useradd --create-home --shell /bin/bash appuser

#----
# builder - uv venv
#----
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential git curl ca-certificates \
&& rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /src

COPY pyproject.toml uv.lock ./

# Cache uv 
RUN --mount=type=cache,target=/root/.cache/uv \
uv sync --frozen --no-install-project --no-dev

COPY src ./src

RUN --mount=type=cache,target=/root/.cache/uv \
uv sync --frozen --no-dev

#----
# final: minimal runtime
#----

FROM base AS final

COPY --from=builder /src/.venv /src/.venv
COPY --from=builder /src/src /src/src

ENV PATH="/src/.venv/bin:$PATH"

RUN chown -R appuser:appuser /src
USER appuser

WORKDIR /src/src
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

