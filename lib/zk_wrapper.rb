path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

require "#{path}/zk_wrapper/zookeeper_dumper.rb"
require "#{path}/zk_wrapper/zookeeper_loader.rb"
require "#{path}/zk_wrapper/mock_zookeeper_dumper.rb"
