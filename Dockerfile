# Use Python 3.11.8 slim version as the base image
FROM python:3.11.8-slim

# Use connection in RAILWAYS Deployment tool
ARG FLASK_DEBUG
ARG FLASK_ENV
ARG DATABASE_TYPE
ARG DATABASE_NAME
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_USER
ARG DATABASE_PASSWORD

# Update the package lists and install necessary dependencies
RUN apt-get update && apt-get install -y \
        libpq-dev \
        gcc \
        && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip3 install poetry

# Set environment variables for Poetry
ENV POETRY_NO_INTERACTION=1 \
        POETRY_VIRTUALENVS_IN_PROJECT=1 \
        POETRY_VIRTUALENVS_CREATE=1 \
        POETRY_CACHE_DIR=/tmp/poetry_cache

# Set the working directory in the container
WORKDIR /app

# Copy the poetry configuration files
COPY pyproject.toml poetry.lock* /app/

# Install project dependencies using Poetry
RUN poetry install

# Copy the rest of the application code
COPY . /app

# Run database migrations (Assuming you're using Flask-Migrate)
RUN poetry run flask db upgrade

# Command to start the application using Gunicorn
CMD [ "/app/.venv/bin/gunicorn","-w", "4", "-b", "0.0.0.0:5000", "app:app"]