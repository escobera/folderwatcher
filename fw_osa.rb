# DOESNT WORK, HERE JUST FOR REFERENCE
require "rbosa"
require "yaml"

class ItunesUpdater
  attr_accessor :config_file
  attr_accessor :filters
  
  def initialize
    @itunes = OSA.app('iTunes')
    @pending = []
    @config_file = File.expand_path("~/.itunes_updater.yml")
    @filters = []
    
    parse_config_file
  end
  
  def pending
    libraries.each do |lib|
      lib_folder = File.expand_path(lib)
      @pending << Dir.glob(lib_folder+"/**/*.mp3")
    end
    
    @pending.sort
  end
  
  def update!
    pending.each do |album|
      @itunes.add(album)
    end
    
    @config["updated_at"] = Time.now.to_s
    
    if !save_config_file
      puts "-- unable to save configuration file on #{@config_file.inspect}"
    end
    
    @pending = []
  end
  
  def updated_at
    @config["updated_at"] ? Time.parse(@config["updated_at"].to_s) : (Time.now - (60 * 60 * 24 * 30 * 365))
  end
  
  def libraries
    @config["libraries"] || []
  end
  
  def libraries=(paths)
    @config["libraries"] = paths
  end
  
  def filters
    (@config["filters"] || []).map do |filter|
      filter = File.expand_path(filter)
      filter.downcase
    end
  end
  
  def notify(message)
    title = "iTunes Library Updater"
    image = "/Applications/iTunes.app/Contents/Resources/iTunes.icns"
    system("growlnotify -n itunes_library_updater --image #{image} -p 2 -m \"#{message}\" -t \"#{title}\" -wait")
  end
  
  def create_template
    template = <<YML
updated_at:
libraries: 
  - ~/Music/iTunes/iTunes Music
filters:
  - <ADD THE FOLDER YOU WANT TO SKIP>
YML
    File.open(@config_file, "w+") << template
  end
  
  private
    def skip_folder?(folder)
      # check if folder is represented by . or ..
      return true if folder =~ /\/\.{1,2}/
      # check if is directory
      return true unless File.directory?(folder)
      # check if folder is in the filter list
      return true if filters.include?(folder.downcase)
      # check the modification timestamp
      return true if File.mtime(folder) < updated_at
      # the folder is ok to go
      return false
    end
    
    def parse_config_file
      @config = YAML.load_file(@config_file)
    rescue
      @config = {
        "updated_at" => nil,
        "libraries" => [],
        "filters" => []
      }
    end
    
    def save_config_file
      File.open(@config_file, "w+") do |file|
        YAML.dump(@config, file)
      end
      
      return true
    rescue
      return false
    end
end

if $0 == __FILE__
  itunes = ItunesUpdater.new
  if File.exists?(itunes.config_file)
    pending_items = itunes.pending.size

    if pending_items > 0
      itunes.notify("#{pending_items} pending folder(s)")
      itunes.update!
      itunes.notify("Library updated!")
    else
      itunes.notify("No pending items found")
    end
  else
    puts 1
    itunes.create_template
    itunes.notify("The configuration file has been created.\n\nIf you need to customize it, edit the file #{itunes.config_file}")
  end
end