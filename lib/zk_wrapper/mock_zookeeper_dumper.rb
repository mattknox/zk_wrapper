class MockZookeeperDumper
  # this mock allows a ruby environment to get static config from yaml,
  # with an interface identical to the zookeeper store.

  class BadPathError < StandardError; end

  def initialize(root_dir, writeable_paths_regex = /decider_ephemeral/)
    @root_dir = root_dir
    @data = { }
  end

  def dump(node)
    filename, *keys = extract_filename(node)

    @data[filename] ||= YAML.load(File.open(filename))
    if keys.blank?
      @data[filename]
    else
      keys.inject(@data[filename]) {|hash, key| hash[key] }
    end
  rescue NoMethodError, Errno::ENOENT
    nil
  end

  def set_value(node, value)
    filename, *keys = extract_filename(node)
    raise BadPathError unless filename.match(writeable_paths_regex)

    @data[filename] ||= (YAML.load(File.open(filename)) rescue {})
    puts keys[0..-2].inspect
    keys[0..-2].inject(@data[filename]) {|hash, key| hash[key] ||= {} }[keys.last] = value
    File.open(filename, "w") do |f|
      f.write @data[filename].to_yaml
      @data[filename] = nil
    end
  end

  def extract_filename(node)
    path_elements = node.split("/")
    if File.exists? "#{node}.yml" # We were given an absolute path
      ["#{node}.yml"]             # TODO: deal with the case in which part of the path is yml and part is hash keys.
    elsif path_elements.first(2) == ["", "config"]
      ["#{@root_dir}/config/#{path_elements[2]}.yml"] + path_elements[3..-1]
    else
      raise BadPathError
    end
  end
end
