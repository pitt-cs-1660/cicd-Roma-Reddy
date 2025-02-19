# Stage 1: Builder Stage
FROM python:3.11-buster AS builder

# Set WORKDIR to /app
WORKDIR /app

# Install Poetry and upgrade pip
RUN pip install --upgrade pip && pip install poetry

# Copy the dependency files first
COPY pyproject.toml poetry.lock ./

# Build the application using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Copy the application code
COPY . .

# Stage 2: Final Application Stage
FROM python:3.11-buster AS app

# Set WORKDIR to /app
WORKDIR /app 

# Copy the built application from the builder stage
COPY --from=builder /app /app

# Expose port 8000 for FastAPI to be accessible
EXPOSE 8000

# Set the entrypoint.sh as the entrypoint for the container
ENTRYPOINT ["/app/entrypoint.sh"]

# Set the CMD parameter to run the FastAPI application
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
