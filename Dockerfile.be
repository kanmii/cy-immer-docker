FROM node:14.9-buster-slim AS be

ARG NODE_ENV

ENV BUILD_DEPS="build-essential" \
  APP_DEPS="curl iputils-ping" \
  NODE_ENV=$NODE_ENV \
  IMMER_CY_APP_NAME="be"

ADD \
  https://raw.githubusercontent.com/humpangle/wait-until/v0.1.1/wait-until \
  /usr/local/bin

COPY \
  ./entrypoint.sh \
  /usr/local/bin

RUN \
  chmod 755 /usr/local/bin/wait-until && \
  chmod 755 /usr/local/bin/entrypoint.sh && \
  mkdir -p /home/node/immer-cy/_shared &&  \
  mkdir -p /home/node/immer-cy/packages/shared &&  \
  mkdir -p /home/node/immer-cy/packages/be && \
  chown -R node:node /home/node && \
  apt-get update && \
  apt-get install -y --no-install-recommends ${BUILD_DEPS} &&  \
  [ $NODE_ENV != "production" ] &&  \
    apt-get install -y --no-install-recommends ${APP_DEPS} &&  \
  rm -rf /var/lib/apt/lists/* &&  \
  rm -rf /usr/share/doc && rm -rf /usr/share/man &&  \
  apt-get purge -y --auto-remove ${BUILD_DEPS} &&  \
  apt-get clean

USER node

WORKDIR /home/node/immer-cy

######### ROOT FILES ##########
COPY  \
  ./package-scripts.js \
  ./package.json \
  ./yarn.lock \
  ./.yarnrc \
  ./

########## SHARED FOLDER ##########
COPY  \
  ./_shared \
  ./_shared/

######## PACKAGES/SHARED ##########
COPY  \
  ./packages/shared \
  ./packages/shared/
######## END PACKAGES/SHARED ########

######## CRA ##########
COPY  \
  ./packages/be \
  ./packages/be/
######## END CRA ########

RUN \
  yarn install --frozen-lockfile

CMD ["/bin/bash"]