#!/usr/bin/bash

# Set up our build specific directories for jruby
export GEM_HOME=vendor/gem_home
export GEM_PATH=$GEM_HOME

# Install bundler for use with jruby
jruby -S gem install -i "$GEM_HOME" --no-rdoc --no-ri bundler

# Install our deps
jruby -S bundle install

# Build our filter plugin
jruby -S gem build logstash-filter-edn.gemspec
