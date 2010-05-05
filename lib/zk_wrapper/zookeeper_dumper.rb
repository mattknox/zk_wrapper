class ZookeeperDumper

  class NonLeafNodeError < StandardError; end
  def initialize(zookeeper)
    @zk = zookeeper
  end

  def dump(node)
    YAML.load(@zk.get(node)[0]) rescue 'BORKED!!!!!'
  end

  def dump_multinode(node)
    if leaf_node?(node)
      # evaluate the contents of the node as data
      parse_string(@zk.get(node)[0])
    elsif looks_like_array?(node)
      get_indices(@zk.get_children(node)).map { |elt| dump(new_node(node, elt))}
    else
      # this builds up a hash from the ZK state rooted at node.
      @zk.get_children(node).inject({}) do |hash, child_node|
        hash[child_node] = dump(new_node(node, child_node))
        hash
      end
    end
  end

  def set_value(node, value)
    # this will unconditionally set the value of a node to value
    if leaf_node?(node)
      @zk.set(path, value.inspect, -1)
    else
      # values on non-leaf-nodes will be ignored when dumped, so we don't allow them to be set.
      raise NonLeafNodeError
    end
  end

  private
  def leaf_node?(node)
    @zk.get_children(node).blank?
  end

  def parse_string(elt)
    if elt.match(/^\d+$/)
      elt.to_i
    elsif elt.match(/^\d+\.\d+/)
      elt.to_f
    elsif elt.match(/^:([a-zA-Z0-9_]+)/)
      $1.to_sym
    elsif elt.match(/^'.*'$|^".*"$/)
      elt[1..-2]
    elsif elt.match(/^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/)
      Time.parse(elt)
    elsif "true" == elt
      true
    elsif "false" == elt
      false
    elsif "" == elt
      nil
    else
      elt
    end
  end

  def looks_like_array?(node)
    # arrays are denoted by mostly contiguous numeric keys 1..end
    # we exclude 0 because  "foo".to_i => 0
    children = @zk.get_children(node)
    children.length == get_indices(children).length
  end

  def get_indices(arr)
    # this converts an array of strings into indices
    names = arr.map { |x| x.to_i }.sort
    max_acceptable_value = names.length * 2
    names.reject { |x| x < 1 || x > max_acceptable_value }.uniq
  end

  def new_node(root, child)
    if "/" == root
      "/#{child}"
    else
      "#{root}/#{child}"
    end
  end

  def zk_load(x, node)
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
end
