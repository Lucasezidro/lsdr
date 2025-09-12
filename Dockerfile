# Dockerfile

# Stage 1: Build environment
FROM docker.io/library/ruby:3.2.2-slim AS builder
LABEL maintainer="Lucas Ezidro <lucasezidro7@gmail.com>"

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential git libpq-dev libyaml-dev \
      postgresql-client libvips libvips-dev && \
      build-essential git libpq-dev libyaml-dev pkg-config cron && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory for the application
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems without the frozen flag, for development
RUN bundle install

# Stage 2: Final image
FROM docker.io/library/ruby:3.2.2-slim
LABEL maintainer="Lucas Ezidro <lucasezidro7@gmail.com>"

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      curl libjemalloc2 postgresql-client libvips && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory for the application
WORKDIR /app

# Copy the application code
COPY . .

# Copy gems from the builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# The command to run the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]