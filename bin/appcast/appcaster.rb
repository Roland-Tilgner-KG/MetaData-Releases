#!/usr/bin/env ruby

require 'bundler/setup'
require 'rexml/document'
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
require_relative 'lib/appcast'

class Optparse

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.library = []
    options.inplace = false
    options.encoding = "utf8"
    options.transfer_type = :auto
    options.verbose = false
    options.appcast_name = "meta|data"
    options.appcast_description = "meta|data"
    options.download_url = "https://roland-tilgner-kg.github.io/MetaData-Releases"
    options.author = "Roland Tilgner KG"
    
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: appcaster.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"
        # Cast 'appcast_path' argument to a String.
        opts.on("-o", "--output [PATH]", String, "Local Path to the appcast.xml") do |output|
            options.output = output
        end

        # Cast 'update_path' argument to a String.
        opts.on("-p", "--path [PATH]", String, "Path to the download folder") do |download_path|
            options.download_path = download_path
        end

        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
        end
    end

    opts.parse!(args)
    options
  end  # parse()

end  # class Optparse

options = Optparse.parse(ARGV)
output_path = options.output
output_file_exists = !output_path.nil? && !output_path.empty? && File.file?(output_path)
appcast_url = "#{options.download_url}/appcast.xml"

File.delete(output_path) if output_file_exists

appcast = Screenhero::Sparkle::AppCast.new(
    name: options.appcast_name, 
    description: options.appcast_description,
    appcast_url: appcast_url)

if !output_path.nil? && !output_path.empty?
    appcast.write(path: output_path)
else 
    puts appcast.to_s
end    



Dir.glob("#{options.download_path}/?.?.?").sort.each do |folder|
  version = File.basename(folder).to_s
  folder_to_update_path = File.expand_path(folder).to_s
  update_path = "#{folder_to_update_path}/metadata-#{version}.zip"
  update_url = "#{options.download_url}/downloads/#{version}/metadata-#{version}.zip"
  release_notes_url = "#{options.download_url}/release-notes/#{version}/release_notes.html"
  
  appcast.add_item(
      version: options.version, 
      author: options.author, 
      update_path: update_path,
      update_url: update_url, 
      release_notes_url: release_notes_url)

end

appcast.write(path: output_path)

  