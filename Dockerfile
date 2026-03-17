### MORPHOSOURCE-BUILD STAGES (BUILDS APP FILES FOR LATER COPYING) ###

### MORPHOSOURCE-BUILD-DEV STAGE ####

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-base:0.0.2 AS morphosource-build-dev

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

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-base:0.0.2 AS morphosource-build-prod

ARG APP_PATH=.
ARG SECRET_KEY_BASE

USER app

COPY --chown=1001:0 $APP_PATH/Gemfile $RAILS_ROOT/Gemfile
COPY --chown=1001:0 $APP_PATH/Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle install --jobs "$(nproc)" --without development

COPY --chown=1001:0 $APP_PATH/package.json $RAILS_ROOT/package.json
COPY --chown=1001:0 $APP_PATH/yarn.lock $RAILS_ROOT/yarn.lock
RUN yarn install

COPY --chown=1001:0 $APP_PATH $RAILS_ROOT

RUN NODE_OPTIONS=--openssl-legacy-provider RAILS_ENV=development bundle exec rails assets:precompile

# Set directories as executable for writeability
RUN chmod -R g+rwX $RAILS_ROOT



### MORPHOSOURCE-DEV STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-base:0.0.2 AS morphosource-dev

COPY --chown=1001:0 --from=morphosource-build-dev $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-PROD STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-base:0.0.2 AS morphosource-prod

COPY --chown=1001:0 --from=morphosource-build-prod $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]



### MORPHOSOURCE-WORKER-DEV STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-worker-base:0.0.3 AS morphosource-worker-dev

COPY --chown=1001:0 --from=morphosource-build-dev $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "resque-pool"]



### MORPHOSOURCE-WORKER-PROD STAGE
# To decrease container size, this stage does not inherit from build stage but just copies files from it

FROM gitlab-registry.oit.duke.edu/morphosource/morphosource/morphosource-worker-base:0.0.3 AS morphosource-worker-prod

COPY --chown=1001:0 --from=morphosource-build-prod $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["hyrax-entrypoint.sh"]
CMD ["bundle", "exec", "resque-pool"]
