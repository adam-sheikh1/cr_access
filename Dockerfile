ARG BASE_NAME=ruby
ARG BASE_TAG=2.7.1-slim
ARG BASE_IMAGE=${BASE_NAME}:${BASE_TAG}

FROM ${BASE_IMAGE} as Builder

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL en_US.UTF-8

RUN apt-get update -qq \
  && apt-get install -y locales \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen \
  && apt-get install -y \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  git \
  imagemagick \
  libpq-dev \
  shared-mime-info \
  && curl -sL https://deb.nodesource.com/setup_15.x | bash \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
  > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile* /app/
RUN gem install bundler \
 && bundle config --local frozen 1 \
 && bundle config --local without "development test" \
 && bundle install -j4 --retry 3 \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

RUN bundle exec wkhtmltopdf --version

COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app

RUN RAILS_ENV=production \
    PRECOMPILE=true \
    SECRET_KEY_BASE=no \
    bundle exec rake assets:precompile && \
    rm -rf node_modules tmp/cache spec

# Build Step Done

FROM ${BASE_IMAGE}

RUN apt-get update -qq \
  && apt-get install -y \
    curl \
    imagemagick \
    libjemalloc2 \
    nodejs \
    poppler-utils \
    postgresql-client \
    shared-mime-info \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 app && \
  useradd --uid 1000 --no-log-init --create-home --gid app app
USER app

COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app /app /app

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV EXECJS_RUNTIME Disabled

WORKDIR /app

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
