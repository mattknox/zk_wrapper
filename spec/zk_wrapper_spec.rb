require 'spec_helper'

describe ZookeeperDumper do

  before do
    @z  = Zookeeper.new("localhost:")
    @zk = ZookeeperDumper.new
  end

  describe "#dump and #load" do

  end
end
