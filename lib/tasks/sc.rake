#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))

namespace :sc do
  desc 'Enqueues profile crawler.'
  task :crawl do
    Resque.enqueue(ProfileCrawler, 10)
  end
end