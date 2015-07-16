require_relative "requirer/version"

module Requirer
  class DirUtilsException < StandardError ; end

  def require_dir_tree(path)
    # "dir_tree #{path}".logit
    path = find_dir_with(path, $LOAD_PATH)
    on_dir_tree(path) do |dir_path|
      require_absolute_dir dir_path
    end
  end

  def require_dir(path)
    # "require_dir #{path}".logit
    require_absolute_dir find_dir_with(path, $LOAD_PATH)
  end


  def require_absolute_dir(path)
    return nil unless path

    # "requiring_absolute_dir #{path}".logit
    Dir["#{path}/[^_]*.rb"].sort.each do |file|
      next unless File.file?(file)
      # "requiring #{file}".logit
      require file
    end
  end

  def find_dir_with(path, search_dirs=$LOAD_PATH)
    fail DirUtilsException.new("No such path: #{path}") unless path
    path = path.to_s
    return path if path[0]=='/'
    search_dirs.each do |dir|
      dirname = File.expand_path(path, dir)
      return dirname if File.directory?(dirname)
    end
    fail DirUtilsException.new("No such path: #{path}")
  end

  def find_file_with(path, search_dirs=$LOAD_PATH)
    fail DirUtilsException.new("No such path: #{path}") unless path
    if path[0]=='/'
      fail DirUtilsException.new("No such path: #{path}") unless File.exists?(path)
      return path
    end
    search_dirs.each do |dir|
      filename = File.expand_path(path, dir)
      return filename if File.file?(filename)
    end
    fail DirUtilsException.new("No such path: #{path}")
  end

  def where_is?(path)
    find_file_with path
  end

  def on_dir_tree(path, &block)
    return nil unless path
    block.call path
    dirs = Dir["#{path}/*"].select{ |f| File.directory?(f) }
    dirs.each{ |dir| on_dir_tree dir, &block }
  end
end
