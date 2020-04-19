#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "mini_magick"
require "erb"

class PhotoBatch

  def initialize(base_folder)
    puts "Starting New instance of PhotoBatch"
    puts "Using #{base_folder} as base source-folder"

    @config = Hash.new
    @config[:thumb_size] = "250"
    @config[:base_folder] = base_folder
    @config[:html_title] = "Blandade album"
    @config[:html_heading] = "Randombilder från kameran"


  end

  #
  # Handle single photo
  def handlePhoto(photo_path, save_location, album)
    file_name = photo_path.split("/").last.split(".").first
    short_name = File.basename(file_name)
    burn_text = "#{album} -- #{short_name}"
    puts "Photoname:".ljust(30) + "#{file_name}"

    out_name = save_location + file_name
    
    thumbnail_data = writeThumb(photo_path, out_name, @config[:thumb_size], burn_text)
    realimage_data = writeImage(photo_path, out_name, 1080, burn_text + " -- Sebastian Thörn")
    
    @images.push({thumbnail: thumbnail_data, realimage: realimage_data})
    #pp @images
  end

  #
  # Create new image
  def writeImage(source, destination, height, burn_text)
    t_now = Time.now
    out_name = destination + "_#{height}.png"
    image_data = Hash.new
    image_data[:path] = out_name

    image = MiniMagick::Image.open(source)

    # Only generate files if they don't exist
    if File.file?(out_name)
      puts "* File exists:".ljust(30) + "#{out_name}"
    else

      # Funkar bra, ej rekomenderad
      #image.combine_options do |b|
      #  b.resize "x#{height}"
      #  b.font "Helvetica"
      #  b.fill "white"
      #  b.pointsize 40
      #  b.draw "text 20,#{height-20} \"#{burn_text}\""
      #  b.quality "100"
      #end

      image.combine_options do |b|
        b.resize "x#{height}"
        b.font "Helvetica"
        b.fill "white"
        b.pointsize 40
        b.draw "text 20,#{height-20} \"#{burn_text}\""
        b.quality "100"
      end

      image.format "png"
      image.write(out_name)
      puts "* Wrote file:".ljust(30) + "#{out_name} in #{(Time.now - t_now).round(2)} sec"
    end

    #image_data[:model] = image.details["Model"]

    pp image_data
    return image_data
  end

  #
  # Create new image
  def writeThumb(source, destination, height, burn_text)
    t_now = Time.now
    out_name = destination + "_#{height}.png"
    image_data = Hash.new
    image_data[:path] = out_name

    #image = MiniMagick::Image.open(source)

    # Only generate files if they don't exist
    if File.file?(out_name)
      puts "* File exists:".ljust(30) + "#{out_name}"
    else
      image = MiniMagick::Image.open(source)
      image.combine_options do |b|
        b.resize "#{height}x#{height}"
        b.font "Helvetica"
        b.fill "white"
        b.draw "text 5,160 \"#{burn_text}\""
        b.quality "100"
      end
      image.format "png"
      image.write(out_name)

      # gm convert -font Helvetica -fill blue -draw "text 100,100 Cockatoo" IMG_9588.JPG IMG_9588_text.JPG

      image = MiniMagick::Image.open(out_name)
      image.combine_options do |b|
        b.gravity "center"
        b.extent "#{height.to_i+10}"
        b.background "black"
        b.quality "100"
      end
      image.format "png"
      image.write(out_name)
      puts "* Wrote file:".ljust(30) + "#{out_name} in #{(Time.now - t_now).round(2)} sec"
    end
    
    #image_data[:model] = image.details["Model"]

    pp image_data
    return image_data
  end

  def newAlbum(folder, album)
    puts "Looking in:".ljust(30) + "#{folder}"

    @images = Array.new
    save_location = "out" + "/" + folder + "/"

    # Handle images
    Dir.glob(@config[:base_folder] + "/" + folder + "/*").each do|file|
        puts
        puts "Filepath:".ljust(30) + "#{file}"

        unless File.directory?(save_location)
          FileUtils.mkdir_p(save_location)
        end

        handlePhoto(file, save_location, album)
    end

    puts "\nmini-wrapper"
    puts "  Wrapping albums into index.html"
    # Handle index.html
    filename = "index_album.erb"

    erb = ERB.new(File.read(filename))
    html = erb.result_with_hash(
      title: @config[:html_title],
      images: @images,
      image_height: @config[:image_height],
      heading: @config[:html_heading]
    )

    pp Dir.entries(".")
    File.write(save_location + "index.html", html)


  end

  def wrapper()
    puts "\ndef wrapper"
    puts "  Wrapping folders into index.html"
    # Handle index.html
    filename = "index_main.erb"
    folders = Dir.glob("out/*").select {|f| File.directory? f}
    #folders.select!{|f|f.}
    folders.map!{|f|f.split("/").last}
    pp folders


    erb = ERB.new(File.read(filename))
    html = erb.result_with_hash(
      title: @config[:html_title],
      folders: folders,
      heading: @config[:html_heading]
    )

    File.write("out/index.html", html)

    # Handle static files
    FileUtils.cp(Dir.glob("static/*"), "out/.")
  end

end
