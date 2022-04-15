ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-alpine3.14 as msbase

ARG DATABASE_APK_PACKAGE="postgresql-dev"
ARG EXTRA_APK_PACKAGES="git"

RUN apk --no-cache upgrade && \
  apk --no-cache add build-base \
  bash \
  curl \
  curl-dev \
  ffmpeg \
  gcompat \
  imagemagick \
  mediainfo \
  openjdk11-jre \
  perl \
  tzdata \
  nodejs \
  npm \
  yarn \
  zip \
  $DATABASE_APK_PACKAGE \
  $EXTRA_APK_PACKAGES

RUN addgroup -S --gid 101 app && \
  adduser -S -G app -u 1001 -s /bin/sh -h /app app
USER app

RUN mkdir -p /app/samvera/hyrax-webapp
WORKDIR /app/samvera/hyrax-webapp

ENV PATH="/app/samvera/hyrax-webapp/bin:$PATH"
ENV RAILS_ROOT="/app/samvera/hyrax-webapp"
ENV RAILS_SERVE_STATIC_FILES="1"

# RUN gem update bundler
ENV BUNDLE_GEMFILE="./Gemfile"
ENV BUNDLER_VERSION='2.0.2'
RUN gem install bundler -v 2.0.2

ARG APP_PATH=.
COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]


FROM msbase as morphosource

ARG BUNDLE_WITHOUT="development test"
ENV BLENDER_PATH="/app/blender/"

RUN bundle install --jobs "$(nproc)"
RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rails assets:precompile


FROM msbase as mstools

# Install GLTF Pipeline 3D mesh derivative tool
USER root
RUN npm install --global gltf-pipeline
USER app

ENV FITS_VERSION='1.3.0'

# Install FITS characterization tool
RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
COPY ./vendor/fits_config/fits.xml /app/fits/xml
COPY ./vendor/fits_config/exiftool/exiftool_dicom_to_fits.xslt /app/fits/xml/exiftool
COPY ./vendor/fits_config/exiftool/exiftool_xslt_map.xml /app/fits/xml/exiftool
ENV PATH="${PATH}:/app/fits"

# Install Blender 3D mesh derivative tool
RUN mkdir -p /app/blender && \
    cd /app/blender && \
    wget https://download.blender.org/release/Blender2.82/blender-2.82-linux64.tar.xz -O blender.tar.xz && \
    tar -Jxvf blender.tar.xz -C /app/blender --strip-components=1 && \
    rm blender.tar.xz
ENV BLENDER_PATH="/app/blender/"

# Install Fiji 3D CT stack derivative tool
RUN mkdir -p /app/fiji && \
    cd /app/fiji && \
    wget https://github.com/MorphoSource/fiji-app-pinned/releases/download/2.3.0/fiji-nojre-2.3.0.zip -O fiji.zip && \
    unzip fiji.zip && \
    rm fiji.zip

# Install DICOM Toolkit (dcmtk) 3D CT stack derivative tool
RUN mkdir -p /app/dcmtk && \
    cd /app/dcmtk && \
    wget https://dicom.offis.de/download/dcmtk/dcmtk364/bin/dcmtk-3.6.4-linux-x86_64-static.tar.bz2 -O dcmtk.tar.bz2 && \
    tar -jxvf dcmtk.tar.bz2 -C /app/dcmtk --strip-components=1 && \
    rm dcmtk.tar.bz2 && \
    chmod -R -c +x /app/dcmtk/bin
ENV PATH="${PATH}:/app/dcmtk/bin"


FROM mstools as msworkerbase

ENV MALLOC_ARENA_MAX=2

CMD bundle exec sidekiq


FROM msworkerbase as msworker

ARG BUNDLE_WITHOUT="development test"
ENV BLENDER_PATH="/app/blender/"

RUN bundle install --jobs "$(nproc)"
RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rails assets:precompile
