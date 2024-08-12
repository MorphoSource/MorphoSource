### MORPHOSOURCE-BUILD STAGE (BUILDS APP FILES FOR LATER COPYING) ###

ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-bullseye as morphosource-build

ARG RAILS_ROOT=/app/samvera/hyrax-webapp
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

RUN apt update && \
  apt install -y --no-install-recommends \
  libcurl4 \
  imagemagick \
  netcat \
  nodejs \
  npm \
  perl \
  tzdata \
  zip \
  $DATABASE_APK_PACKAGE \
  $EXTRA_APK_PACKAGES && \
  rm -rf /var/lib/apt/lists/* 

RUN adduser --system --gid 0 --uid 1001 --home /app app
USER app

RUN mkdir -p $RAILS_ROOT
# For K8s OpenShift, ensure all files and directories are readable and executable by group 0
RUN chgrp -R 0 $RAILS_ROOT && \
    chmod -R g+rwX $RAILS_ROOT
WORKDIR $RAILS_ROOT

ENV PATH="$RAILS_ROOT/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:$LD_LIBRARY_PATH"
ENV RAILS_ROOT=$RAILS_ROOT
ENV RAILS_SERVE_STATIC_FILES="1"

# RUN gem update bundler
ENV BUNDLE_GEMFILE="./Gemfile"
ENV BUNDLER_VERSION='2.0.2'
ENV HOME=$RAILS_ROOT
RUN gem install bundler -v 2.0.2



### MORPHOSOURCE-BUILD-DEV STAGE ####

FROM morphosource-build as morphosource-build-dev

ARG APP_PATH=.
ARG BUNDLE_WITHOUT

USER app

COPY --chown=1001:0 $APP_PATH/Gemfile $RAILS_ROOT/Gemfile
COPY --chown=1001:0 $APP_PATH/Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle config --global && \
  bundle install --jobs "$(nproc)" --path=vendor/bundle

COPY --chown=1001:0 $APP_PATH $RAILS_ROOT

# Set directories as executable for writeability
RUN chmod -R g+rwX $RAILS_ROOT



### MORPHOSOURCE-BUILD-PROD STAGE ###

FROM morphosource-build as morphosource-build-prod

ARG APP_PATH=.
ARG BUNDLE_WITHOUT
ARG SECRET_KEY_BASE

USER app

COPY --chown=1001:0 $APP_PATH/Gemfile $RAILS_ROOT/Gemfile
COPY --chown=1001:0 $APP_PATH/Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle config --global && \
  bundle install --jobs "$(nproc)" --path=vendor/bundle

COPY --chown=1001:0 $APP_PATH $RAILS_ROOT

RUN RAILS_ENV=development bundle exec rake assets:precompile

# Set directories as executable for writeability
RUN chmod -R g+rwX $RAILS_ROOT



### MORPHOSOURCE-BASE STAGE ###

ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-bullseye as morphosource-base

ARG RAILS_ROOT=/app/samvera/hyrax-webapp
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

RUN apt update && \
  apt install -y --no-install-recommends \
  libcurl4 \
  imagemagick \
  netcat \
  nodejs \
  npm \
  perl \
  rsync \
  tzdata \
  zip && \
  rm -rf /var/lib/apt/lists/*

RUN adduser --system --gid 0 --uid 1001 --home /app app
USER app

WORKDIR $RAILS_ROOT

ENV PATH="$RAILS_ROOT/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:$LD_LIBRARY_PATH"
ENV RAILS_ROOT=$RAILS_ROOT
ENV RAILS_SERVE_STATIC_FILES="1"

# RUN gem update bundler
ENV BUNDLE_GEMFILE="./Gemfile"
ENV BUNDLER_VERSION='2.0.2'
ENV HOME=$RAILS_ROOT
RUN gem install bundler -v 2.0.2



### MORPHOSOURCE-DEV STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-base as morphosource-dev

COPY --chown=1001:0 --from=morphosource-build-dev $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-PROD STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-base as morphosource-prod

COPY --chown=1001:0 --from=morphosource-build-prod $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-WORKER-BASE STAGE ###

FROM morphosource-base as morphosource-worker-base

ENV MALLOC_ARENA_MAX=2

USER root
# Setup for installing Java 8 on Debian 11
RUN apt install -y wget apt-transport-https gpg
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
RUN echo "deb https://packages.adoptium.net/artifactory/deb \
  $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
  | tee /etc/apt/sources.list.d/adoptium.list

# Add bullseye-backports to get 7zip package
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" \
  > /etc/apt/sources.list.d/backports.list

# Install additional system packages related to tools
RUN apt update && \
  apt install -y \
  temurin-8-jdk \
  blender \
  dcmtk \
  ffmpeg \
  firefox-esr \
  libglu1-mesa \
  python3 \
  python3-pip \
  7zip

# Update node/npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt install -yq nodejs build-essential && \
  npm install -g npm

# Install Python packages
RUN pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir numpy Pillow pydicom

# Install GLTF Pipeline 3D mesh derivative tool, used for creating Draco GLBs
RUN npm install --global gltf-pipeline

# Install GLTF Transform 3D mesh derivative tool, used for simplifying GLTF derivatives and creating Draco GLBs
RUN npm install --global @gltf-transform/cli

# Install gltf-inspect 3D mesh derivative tool, used for characterizing info from GLB/GLTF files
RUN npm install --global @morphosource/gltf-inspect@0.2.0

# Install gltf-scale 3D mesh scaling tool, used for creating GLB derivatives with real world scales
RUN npm install --global @morphosource/gltf-scale@0.0.1

# Create symlink to Firefox (for automated tests)
RUN mkdir -p /opt/firefox && \
    ln -s /usr/bin/firefox /opt/firefox/firefox

USER app

ENV FITS_VERSION='1.5.5'

# Install FITS characterization tool
RUN mkdir -p /app/fits && \
  cd /app/fits && \
  wget https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip -O fits.zip && \
  unzip fits.zip && \
  rm fits.zip && \
  chmod a+x /app/fits/fits.sh
COPY --chown=1001:0 ./vendor/fits_config/fits.xml /app/fits/xml
COPY --chown=1001:0 ./vendor/fits_config/exiftool/exiftool_dicom_to_fits.xslt /app/fits/xml/exiftool
COPY --chown=1001:0 ./vendor/fits_config/exiftool/exiftool_xslt_map.xml /app/fits/xml/exiftool
ENV PATH="${PATH}:/app/fits"

# Install Fiji 3D CT stack derivative tool
RUN mkdir -p /app/fiji && \
  cd /app/fiji && \
  wget https://downloads.imagej.net/fiji/releases/2.11.0/fiji-2.11.0-nojre.zip -O fiji.zip && \
  unzip fiji.zip && \
  rm fiji.zip && \
  wget https://raw.githubusercontent.com/MorphoSource/fiji-app-pinned/main/ImageJ.sh -O ./Fiji.app/ImageJ.sh && \
  chmod +x ./Fiji.app/ImageJ.sh



### MORPHOSOURCE-WORKER-DEV STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-worker-base as morphosource-worker-dev

COPY --chown=1001:0 --from=morphosource-build-dev $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "resque-pool"]



### MORPHOSOURCE-WORKER-PROD STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-worker-base as morphosource-worker-prod

COPY --chown=1001:0 --from=morphosource-build-prod $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "resque-pool"]
