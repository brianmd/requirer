require_relative "requirer/version"

alias :require_dependency :require unless Kernel.respond_to?(:require_dependency)

module Requirer
  module_function

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end
  end

  class DirUtilsException < StandardError ; end

  def require_dir_tree(path)
    Requirer.logger.debug "dir_tree #{path}"
    path = find_dir_with(path, $LOAD_PATH)
    on_dir_tree(path) do |dir_path|
      require_absolute_dir dir_path
    end
  end

  def require_dir(path)
    Requirer.logger.debug "require_dir:#{path}:"
    require_absolute_dir find_dir_with(path, $LOAD_PATH)
  end


  def require_absolute_dir(path)
    return nil unless path

    Requirer.logger.debug "requiring absolute dir:#{path}:"
    Dir["#{path}/[^_]*.rb"].sort.each do |file|
      next unless File.file?(file)
      Requirer.logger.debug "requiring file:#{file}:"
      require_dependency file
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
