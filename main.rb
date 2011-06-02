#!/usr/bin/env macruby
require 'appscript'
include Appscript
require 'itunes'

# iTunes Stuff
itunes = ITunesManager.app
itunes.run
itunes_tracks = Array.new
library_playlist = ITunesManager.music
tracks =  library_playlist.fileTracks
tracks.each do |track|
  itunes_tracks.push(track.location.path)
end

# Local Stuff
basedir =  "/Users/rafa/Dropbox"
local_tracks = Dir.glob("#{basedir}/**/*.mp3")

# Diffing local x itunes
dead_tracks = itunes_tracks - local_tracks
tracks_to_add = local_tracks - itunes_tracks

test_track = tracks_to_add.first
url = NSURL.fileURLWithPath(test_track)

p itunes.add(to: url)
