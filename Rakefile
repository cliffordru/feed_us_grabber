# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "feed_us_grabber"
  gem.homepage = "http://github.com/cliffordru/feed_us_grabber"
  gem.license = "MIT"
  gem.summary = %Q{Gem to render feed.us content from your rails app}
  gem.description = %Q{This gem replaces the previous feed.us grabber rails plugin to render content items from feed.us on your site.}
  gem.email = "clifford.gray@gmail.com"
  gem.authors = ["Cliff G"]
  # dependencies defined in Gemfile
  gem.files = Dir.glob('lib/**/*.rb')
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

SimpleCov.start('rails') if ENV['COVERAGE']
desc "Run RSpec with code coverage"
task :coverage do
ENV['COVERAGE'] = true
Rake::Task["spec"].execute
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "feed_us_grabber #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

