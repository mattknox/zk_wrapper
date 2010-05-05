require 'rubygems'
require 'zookeeper'
require "/home/mknox/zookeeper_dumper"
require "/home/mknox/zookeeper_loader"
require "configgy"

z = Zookeeper.new('sjc1k029:2181,sjc1k030:2181,sjc1k031:2181')
zd = ZookeeperDumper.new(z)
zl = ZookeeperLoader.new(z)


configs = { }
configs["decider"] = Hash.new.merge(YAML::load(File.open("#{RAILS_ROOT}/config/decider.yml")))["production"]
configs['kestrel'] = YAML::load(File.open("#{RAILS_ROOT}/vendor/plugins/kestrel-client/config/kestrel.yml"))['production']
configs['readonly_databases'] = YAML.load(File.open("#{RAILS_ROOT}/config/readonly_databases.yml").read)
h1 = YAML::load(File.open("#{RAILS_ROOT}/config/memcached.yml"))
configs['object_cache'] = h1['defaults'].merge(h1['production'])
h = YAML::load(File.open("#{RAILS_ROOT}/config/timeline_cache.yml"))
configs['timeline_cache'] = h['defaults'].merge(h["timeline"]['production'])
configs['flock/edges'] = Configgy.load_file("#{RAILS_ROOT}/config/edges.conf").to_map['production']
node = '/config/readonly_databases'

configs.each do |k,v|
  path = "/config/#{k}"
  puts path
  zl.rm_rf path
  zl.zk_load(v, path)
  puts ( zd.dump(path) == v)
end; nil
