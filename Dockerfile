ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-bullseye as msbase

# ARG DATABASE_APK_PACKAGE="postgresql-dev"
# ARG EXTRA_APK_PACKAGES="git"

RUN apt update && \
  apt install -y \
  libcurl4 \
  imagemagick \
  netcat \
  nodejs \
  npm \
  perl \
  tzdata \
  yarnpkg \
  $DATABASE_APK_PACKAGE \
  $EXTRA_APK_PACKAGES

RUN addgroup --system --gid 501 app && \
  adduser --system --gid 501 --uid 1001 --home /app app
USER app

RUN mkdir -p /app/samvera/hyrax-webapp
WORKDIR /app/samvera/hyrax-webapp

ENV PATH="/app/samvera/hyrax-webapp/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64:/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server:$LD_LIBRARY_PATH"
ENV RAILS_ROOT="/app/samvera/hyrax-webapp"
ENV RAILS_SERVE_STATIC_FILES="1"

# RUN gem update bundler
ENV BUNDLE_GEMFILE="./Gemfile"
ENV BUNDLER_VERSION='2.0.2'
RUN gem install bundler -v 2.0.2

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]

### MS TOOLS STAGE ###
FROM msbase as mstools

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
  python3-pip

# Update node/npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt install -yq nodejs build-essential && \
  npm install -g npm

# Install Python packages
RUN pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir numpy Pillow pydicom

# Install GLTF Pipeline 3D mesh derivative tool, used for creating Draco GLBs
RUN npm install --global gltf-pipeline

# Install gltf-inspect 3D mesh derivative tool, used for characterizing info from GLB/GLTF files
RUN npm install --global @morphosource/gltf-inspect

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
COPY --chown=1001:501 ./vendor/fits_config/fits.xml /app/fits/xml
COPY --chown=1001:501 ./vendor/fits_config/exiftool/exiftool_dicom_to_fits.xslt /app/fits/xml/exiftool
COPY --chown=1001:501 ./vendor/fits_config/exiftool/exiftool_xslt_map.xml /app/fits/xml/exiftool
ENV PATH="${PATH}:/app/fits"

# Install Blender 3D mesh derivative tool
# RUN mkdir -p /app/blender && \
#   cd /app/blender && \
#   wget https://download.blender.org/release/Blender2.82/blender-2.82-linux64.tar.xz -O blender.tar.xz && \
#   tar -Jxvf blender.tar.xz -C /app/blender --strip-components=1 && \
#   rm blender.tar.xz
# ENV BLENDER_PATH="/app/blender/"

# Install Fiji 3D CT stack derivative tool
RUN mkdir -p /app/fiji && \
  cd /app/fiji && \
  wget https://downloads.imagej.net/fiji/releases/2.11.0/fiji-2.11.0-nojre.zip -O fiji.zip && \
  unzip fiji.zip && \
  rm fiji.zip && \
  wget https://raw.githubusercontent.com/MorphoSource/fiji-app-pinned/main/ImageJ.sh -O ./Fiji.app/ImageJ.sh && \
  chmod +x ./Fiji.app/ImageJ.sh

# Install DICOM Toolkit (dcmtk) 3D CT stack derivative tool
# RUN mkdir -p /app/dcmtk && \
#   cd /app/dcmtk && \
#   wget https://dicom.offis.de/download/dcmtk/dcmtk364/bin/dcmtk-3.6.4-linux-x86_64-static.tar.bz2 -O dcmtk.tar.bz2 && \
#   tar -jxvf dcmtk.tar.bz2 -C /app/dcmtk --strip-components=1 && \
#   rm dcmtk.tar.bz2 && \
#   chmod -R -c +x /app/dcmtk/bin
# ENV PATH="${PATH}:/app/dcmtk/bin"

### MS WORKER BASE STAGE ###
FROM mstools as msworkerbase

ENV MALLOC_ARENA_MAX=2

CMD bundle exec sidekiq

### MS WORKER STAGE ###
FROM msworkerbase as msworker

ARG APP_PATH=.
ARG BUNDLE_WITHOUT

COPY --chown=1001:501 $APP_PATH/Gemfile /app/samvera/hyrax-webapp/Gemfile
COPY --chown=1001:501 $APP_PATH/Gemfile.lock /app/samvera/hyrax-webapp/Gemfile.lock
RUN bundle install --jobs "$(nproc)"
# RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rails assets:precompile
# TODO enable production if necessary

COPY --chown=1001:501 $APP_PATH /app/samvera/hyrax-webapp

### MORPHOSOURCE STAGE ###
FROM msbase as morphosource

ARG APP_PATH=.
ARG BUNDLE_WITHOUT

COPY --chown=1001:501 $APP_PATH/Gemfile /app/samvera/hyrax-webapp/Gemfile
COPY --chown=1001:501 $APP_PATH/Gemfile.lock /app/samvera/hyrax-webapp/Gemfile.lock
RUN bundle install --jobs "$(nproc)"
# RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rails assets:precompile
# TODO enable production if necessary

COPY --chown=1001:501 $APP_PATH /app/samvera/hyrax-webapp