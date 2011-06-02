require 'appscript'
include Appscript

itunes = app('iTunes')

itunes_tracks = Array.new

tracks =  itunes.sources["Library"].playlists["Music"].tracks.get
tracks.each do |track|
  itunes_tracks << track.location.get.path
end

# Local Stuff
basedir =  "/Users/rafa/Dropbox"
local_tracks = Dir.glob("#{basedir}/**/*.mp3")

#p local_tracks - [MacTypes::Alias.path("/Users/rafa/Dropbox/Axel Rudi Pell avec Jeff Scott Soto/01 - Return Of The Pharaoh.mp3")]
# Diffing local x itunes
dead_tracks = itunes_tracks - local_tracks
tracks_to_add = local_tracks - itunes_tracks

tracks_to_add.each do |track_path|
  itunes.add(MacTypes::Alias.path(track_path))
end

itunes.delete(tracks_to_add.first)