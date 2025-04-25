# Stage 1: Builder
FROM jekyll/jekyll:4.0 AS builder
WORKDIR /srv/jekyll

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.6.5 --no-document \
  && bundle config set deployment true \
  && bundle config set path 'vendor/bundle' \
  && bundle install --jobs=4 --retry=3

# Build the static site
COPY . .
RUN jekyll build --destination /srv/jekyll/_site

# Stage 2: Production (NGINX)
FROM nginx:1.27-alpine AS runtime
LABEL org.opencontainers.image.authors="Ernest Baker <you@example.com>"

# Copy built site
COPY --from=builder /srv/jekyll/_site /usr/share/nginx/html

# Ensure permissions
RUN chown -R nginx:nginx /usr/share/nginx/html \
  && mkdir -p /var/cache/nginx /var/run/nginx \
  && chown -R nginx:nginx /var/cache/nginx /var/run/nginx

# Expose and run
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]