require 'rubygems'
require 'spec'
require "FileUtils"

def verify_or_setup_zk
  unless File.exists? "../ext/zookeeper-3.3.0"
    curr_dir = FileUtils.pwd
    FileUtils.cd "../ext"
    `tar xvzf zookeeper-3.3.0.tar.gz`
    FileUtils.cd "zookeeper-3.3.0"
    `ant`
    FileUtils.cp "conf/zoo_sample.cfg", "conf/zoo.cfg"
    FileUtils.cd curr_dir
  end
end

def ensure_zk_running
  shellout = `ps -Af | grep -i zookeeper |grep -v grep`
  if shellout.blank?
    verify_or_setup_zk
    `../ext/zookeeper-3.3.0/bin/zkServer.sh start`
  end
end
