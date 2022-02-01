# Based on https://github.com/cypress-io/cypress-docker-images/blob/master/browsers/node16.5.0-chrome97-ff96/Dockerfile
# This image fetches always the latest version of chrome and firefox and not one specified version.

FROM cypress/base:16.5.0

USER root

RUN node --version

# Dependencies for chrome
RUN apt-get update
RUN apt-get install -y fonts-liberation libappindicator3-1 xdg-utils

# Fetching and installing the LATEST chrome
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb
RUN google-chrome --version

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Add zip utility - it comes in very handy
RUN apt-get update && apt-get install -y zip

# add codecs needed for video playback in firefox
# https://github.com/cypress-io/cypress-docker-images/issues/150
RUN apt-get install mplayer -y

# Fetching and installing the LATEST firefox
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && ln -fs /opt/firefox/firefox /usr/bin/firefox

# versions of local tools
RUN echo  " node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "Chrome version:  $(google-chrome --version) \n" \
  "Firefox version: $(firefox --version) \n" \
  "git version:     $(git --version) \n" \
  "whoami:          $(whoami) \n"

# a few environment variables to make NPM installs easier
# good colors for most applications
ENV TERM xterm
# avoid million NPM install messages
ENV npm_config_loglevel warn
# allow installing when the main user is root
ENV npm_config_unsafe_perm true
