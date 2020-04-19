#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "./photobatch.rb"
require "pry"

#
# Start new generation of images
#FileUtils.rm(Dir.glob("out/images/*"))

# Remove static files, keep the folders, we don't wan't to regen those.
FileUtils.rm(Dir.glob("out/*").select {|f| File.file?(f)})

puts
pb = PhotoBatch.new("in")
pb.newAlbum("urbanegoat_2020-04-19", "Urbane Goat, 2020-04-19")
#pb.newAlbum("photos", "Blandade Foton")
pb.wrapper()
