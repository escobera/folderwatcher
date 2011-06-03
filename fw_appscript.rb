# encoding: utf-8
require 'appscript'
include Appscript

itunes = app('iTunes')

itunes_tracks = Array.new
puts "Reading iTunes tracks"
tracks =  itunes.sources["Library"].playlists["Music"].tracks.get
tracks.each do |track|
  itunes_tracks << track.location.get.path
end
puts "Done!"


# Local Stuff
puts "Reading folder tracks"
basedir = "/Volumes/escapsuleDisk/Backup/MP3"
local_tracks = Dir.glob("#{basedir}/**/*.mp3")
puts "Done!"

#p local_tracks - [MacTypes::Alias.path("/Users/rafa/Dropbox/Axel Rudi Pell avec Jeff Scott Soto/01 - Return Of The Pharaoh.mp3")]
# Diffing local x itunes
dead_tracks = itunes_tracks - local_tracks
tracks_to_add = local_tracks - itunes_tracks

#tracks_to_add.each do |track_path|
  #itunes.add(MacTypes::Alias.path(track_path))
#end

#itunes.delete(tracks_to_add.first)

puts dead_tracks
#puts tracks_to_add.count
