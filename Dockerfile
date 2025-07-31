### MORPHOSOURCE-BUILD STAGE (BUILDS APP FILES FOR LATER COPYING) ###

ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-bookworm as morphosource-build

ARG RAILS_ROOT=/app/samvera/hyrax-webapp
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle" \
    BUNDLE_PATH="$RAILS_ROOT/vendor/bundle"

RUN apt update && \
  apt install -y --no-install-recommends \
  libcurl4 \
  imagemagick \
  netcat-traditional \
  nodejs \
  npm \
  perl \
  tzdata \
  zip \
  $DATABASE_APK_PACKAGE \
  $EXTRA_APK_PACKAGES && \
  rm -rf /var/lib/apt/lists/*

# Update node/npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt install -yq nodejs build-essential && \
  npm install -g npm --silent && \
  npm install -g yarn --silent

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


### MORPHOSOURCE-BUILD-DEV STAGE ####

FROM morphosource-build as morphosource-build-dev

ARG APP_PATH=.

USER app

COPY --chown=1001:0 $APP_PATH/Gemfile $RAILS_ROOT/Gemfile
COPY --chown=1001:0 $APP_PATH/Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:0 $APP_PATH/package.json $RAILS_ROOT/package.json
COPY --chown=1001:0 $APP_PATH/yarn.lock $RAILS_ROOT/yarn.lock
RUN yarn install

COPY --chown=1001:0 $APP_PATH $RAILS_ROOT

# Set directories as executable for writeability
RUN chmod -R g+rwX $RAILS_ROOT



### MORPHOSOURCE-BUILD-PROD STAGE ###

FROM morphosource-build as morphosource-build-prod

ARG APP_PATH=.
ARG SECRET_KEY_BASE

USER app

# COPY --chown=1001:0 $APP_PATH/Gemfile $RAILS_ROOT/Gemfile
# COPY --chown=1001:0 $APP_PATH/Gemfile.lock $RAILS_ROOT/Gemfile.lock
# RUN bundle install --jobs "$(nproc)" --without development

# COPY --chown=1001:0 $APP_PATH/package.json $RAILS_ROOT/package.json
# COPY --chown=1001:0 $APP_PATH/yarn.lock $RAILS_ROOT/yarn.lock
# RUN yarn install

COPY --chown=1001:0 $APP_PATH $RAILS_ROOT

# RUN NODE_OPTIONS=--openssl-legacy-provider RAILS_ENV=development bundle exec rails assets:precompile

# Set directories as executable for writeability
RUN chmod -R g+rwX $RAILS_ROOT



### MORPHOSOURCE-BASE STAGE ###

ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-bookworm as morphosource-base

ARG RAILS_ROOT=/app/samvera/hyrax-webapp
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle" \
    BUNDLE_PATH="$RAILS_ROOT/vendor/bundle"

RUN apt update && \
  apt install -y --no-install-recommends \
  libjemalloc2 \
  libcurl4 \
  imagemagick \
  netcat-traditional \
  nodejs \
  npm \
  perl \
  rsync \
  tzdata \
  zip && \
  rm -rf /var/lib/apt/lists/*

# Update node/npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt install -yq nodejs build-essential && \
  npm install -g npm --silent && \
  npm install -g yarn --silent

RUN adduser --system --gid 0 --uid 1001 --home /app app
USER app

WORKDIR $RAILS_ROOT

ENV PATH="$RAILS_ROOT/bin:$PATH"
ENV RAILS_ROOT=$RAILS_ROOT
ENV RAILS_SERVE_STATIC_FILES="1"


### MORPHOSOURCE-DEV STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-base as morphosource-dev

ENV LD_LIBRARY_PATH="/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:$LD_LIBRARY_PATH"
ENV LD_PRELOAD=libjemalloc.so.2

COPY --chown=1001:0 --from=morphosource-build-dev $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-PROD STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM morphosource-base as morphosource-prod

ENV LD_LIBRARY_PATH="/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:$LD_LIBRARY_PATH"
ENV LD_PRELOAD=libjemalloc.so.2

COPY --chown=1001:0 --from=morphosource-build-prod $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-WORKER-BASE STAGE ###

FROM morphosource-base as morphosource-worker-base

USER root
# Setup for installing Java 8 on Debian 11
RUN apt install -y wget apt-transport-https gpg
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
RUN echo "deb https://packages.adoptium.net/artifactory/deb \
  $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
  | tee /etc/apt/sources.list.d/adoptium.list

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

# Install Python packages
# RUN pip3 install --break-system-packages --no-cache-dir --upgrade pip && \
#   pip3 install --break-system-packages --no-cache-dir numpy Pillow pydicom

# Install Python package pymeshlab, which has an annoying quirk for M1 platforms
# ARG TARGETPLATFORM
# RUN if [ "$TARGETPLATFORM" != "linux/arm64" ]; then \
#       pip3 install --break-system-packages --no-cache-dir pymeshlab; \
#     else \
#       wget https://github.com/cnr-isti-vclab/PyMeshLab/releases/download/v2023.12.post2/pymeshlab-2023.12.post2-cp311-cp311-manylinux_2_35_aarch64.whl && \
#       pip3 install --break-system-packages --no-cache-dir pymeshlab-2023.12.post2-cp311-cp311-manylinux_2_35_aarch64.whl && \
#       apt install -y qtbase5-dev; \
#     fi

# Install GLTF Pipeline 3D mesh derivative tool, used for creating Draco GLBs
RUN npm install --global only-allow
RUN npm install --global gltf-pipeline --legacy-peer-deps

# Install GLTF Transform 3D mesh derivative tool, used for simplifying GLTF derivatives and creating Draco GLBs
# RUN npm install --cpu=x64 --os=linux --libc=glibc sharp
RUN npm install --global @gltf-transform/cli@4.0.10

# Install gltf-inspect 3D mesh derivative tool, used for characterizing info from GLB/GLTF files
RUN npm install --global @morphosource/gltf-inspect@0.2.0

# Install gltf-scale 3D mesh scaling tool, used for creating GLB derivatives with real world scales
RUN npm install --global @morphosource/gltf-scale@0.0.1

# Install obj2gltf 3D mesh derivative tool, used for converting OBJ to GLTF creating derivatives
RUN npm install --global obj2gltf

# Create symlink to Firefox (for automated tests)
# RUN mkdir -p /opt/firefox && \
#     ln -s /usr/bin/firefox /opt/firefox/firefox

# Install rclone
# RUN mkdir -p /app/rclone && \
#   cd /app/rclone && \
#   curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
#   unzip rclone-current-linux-amd64.zip && \
#   rm rclone-current-linux-amd64.zip

USER app

ENV FITS_VERSION='1.5.5'

# Install FITS characterization tool
# RUN mkdir -p /app/fits && \
#   cd /app/fits && \
#   wget https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip -O fits.zip && \
#   unzip fits.zip && \
#   rm fits.zip && \
#   chmod a+x /app/fits/fits.sh
# COPY --chown=1001:0 ./vendor/fits_config/fits.xml /app/fits/xml
# COPY --chown=1001:0 ./vendor/fits_config/exiftool/exiftool_dicom_to_fits.xslt /app/fits/xml/exiftool
# COPY --chown=1001:0 ./vendor/fits_config/exiftool/exiftool_xslt_map.xml /app/fits/xml/exiftool
# ENV PATH="${PATH}:/app/fits"

# Install Fiji 3D CT stack derivative tool
# RUN mkdir -p /app/fiji && \
#   cd /app/fiji && \
#   wget https://downloads.imagej.net/fiji/releases/2.11.0/fiji-2.11.0-nojre.zip -O fiji.zip && \
#   unzip fiji.zip && \
#   rm fiji.zip && \
#   wget https://raw.githubusercontent.com/MorphoSource/fiji-app-pinned/main/ImageJ.sh -O ./Fiji.app/ImageJ.sh && \
#   chmod +x ./Fiji.app/ImageJ.sh



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
RUN gltf-transform metalrough '/app/samvera/hyrax-webapp/spec/fixtures/bunny/bunny.glb' output.glb

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "resque-pool"]
