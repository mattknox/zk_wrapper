class ZookeeperLoader
  def initialize(zk)
    @zk = zk
  end

  def zk_load(x, node)
    @zk.create(node, YAML.dump(x), 0)
  end

  def zk_load_multinode(x, node)
    if x.is_a? Hash
      x.keys.each do |name|
        insert_collection_element(node, name, x[name])
      end
    elsif x.is_a? Array
      x.each_with_index do |val, name|
        insert_collection_element(node, name + 1, val)
      end
    else
      insert_collection_element(node, name + 1, x.inspect)
    end
  end

  def insert_collection_element(node, name, val)
    node_name = new_node(node, name)
    if val.is_a? Hash or val.is_a? Array
      @zk.create(node_name, "", 0)
      zk_load(val, node_name)
    else
      @zk.create(node_name, val.inspect, 0)
    end
  end

  def rm_rf(node)
    arr = @zk.get_children(node) rescue []
    # kill children first
    arr.map { |elt| rm_rf(new_node(node, elt)) } unless arr.blank?
    data, stat = @zk.get(node) rescue nil
    @zk.delete node, stat.version if data
  end

  def rm(node, &block)
    arr = @zk.get_children(node)
    if arr.blank?
      data, stat = @zk.get node
      @zk.delete node, stat.version
    else
      arr.map { |elt| block[node, elt] } if block_given?
    end
  end

  def deep_equals(x, y)
    return false unless x.class == y.class

    if x.is_a? Array
      (0..(x.size)).all? { |z| deep_equals(x[z], y[z])}
    elsif x.is_a? Hash
      x.size == y.size && x.keys.all? { |z| deep_equals(x[z], y[z])}
    else
      x == y
    end
  end

  def new_node(root, child)
    if "/" == root
      "/#{child}"
   else
      "#{root}/#{child}"
    end
  end
end
