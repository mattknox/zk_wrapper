require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "zk_wrapper"
    gem.summary = %Q{this wraps zookeeper_client in a more ergonomic wrapper.}
    gem.description = %Q{This wraps zookeeper_client in a more ergonomic wrapper.}
    gem.email = "matthewknox@gmail.com"
    gem.homepage = "http://github.com/mattknox/zk_wrapper"
    gem.authors = ["matt knox"]
    gem.files = [ "lib/zk_wrapper/zookeeper_loader.rb",
                  "lib/zk_wrapper/zookeeper_dumper.rb",
                  "lib/zk_wrapper/mock_zookeeper_dumper.rb",
                  ".document",
                  ".gitignore",
                  "LICENSE",
                  "README.rdoc",
                  "Rakefile",
                  "VERSION",
                  "lib/zk_wrapper.rb",
                  "test/helper.rb",
                  "test/test_zk_wrapper.rb"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zk_wrapper #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
