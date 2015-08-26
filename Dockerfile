FROM atlashealth/ruby:2.2.2

RUN apt-get update \
  && apt-get install -y \
    curl \
    git-core \
    libssl-dev \
    libpq-dev \
    nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

WORKDIR /app
ADD . /app

RUN bundle install --without development

# A bit of a hack to get assets to compile without the usual env vars. There doesn't seem
# to be a way to disable the symmetric-encryption gem, so we just give it an arbitrary key.
RUN SYMMETRIC_ENCRYPTION_KEY=ZkfIjDCGLwG6fcC3yaOyZDxL6wokGRikvUsbdRj+WZOGhhBoIaCkN84ZDYrMp3OczwCABzR5vt/y8v9KdjsjARrkitBKfkCB8/nLbfsHDVHSyOsZAu9vOvkqG08KoT4xaBulE4s2fyb3t7QmKmNJ7g3Z/vg87Wuk10/Y27VDrzeW/BOl9ADEQ0CC526zdDZqzWOb479Pc9rK6Rs0+tQukJy39uHI7TJdXp+Z0JuvOwiMWgd2Du5TeHn62gbbmIuBC8aL/96uDkbVPsL6Aq2M2MrxzcMJ5XF6gLM/nEIIL/6zN+tRmC5HO4WHaMOAV1pvaYQywV1P+Ti2GkmspckX4w== \
  bundle exec rake assets:precompile

ENTRYPOINT ["bundle", "exec"]
