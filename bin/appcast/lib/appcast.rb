require 'base64'
require 'nokogiri'
require 'openssl'
require 'rexml/document'

module Screenhero
  module Sparkle
    class AppCast
      class Item
        def initialize(name: '', author: '', update_path: '', version: '0.0.0',
          publish_date: Time.now, update_url: '', release_notes_url: '',
          minimum_system_version: nil)

          if File.file?(update_path)
            @publish_date = File::Stat.new(update_path).ctime
            @update_length = File.size?(update_path)
          else
            @publish_date = publish_date
            @update_length = 0
          end
          @name = name
          @author = author
          @update_path = update_path
          @version = version
          @update_url = update_url
          @release_notes_url = release_notes_url
          @update_signature = nil
          @minimum_system_version = minimum_system_version
          @xml = REXML::Element.new("item")

          generate_xml!
        end

        attr_reader :update_length, :xml

        def generate_xml!
          item = @xml

          item.add_element("title").add_text(@version)
          item.add_element("sparkle:minimumSystemVersion").add_text(@minimum_system_version) if @minimum_system_version
          item.add_element("sparkle:releaseNotesLink").add_text("#{@release_notes_url}")
          item.add_element("description").add_text("#{@release_notes_url}")
          item.add_element("version").add_text(@version)
          item.add_element("author").add_text("#{@author}")
          item.add_element("pubDate").add_text(@publish_date.strftime("%a, %d %h %Y %H:%M:%S %z"))

          guid = item.add_element("guid")
          guid.attributes["isPermaLink"] = "false"
          guid.add_text("#{@name} #{@version}")

          enclosure = item.add_element("enclosure")
          enclosure.attributes["url"] = @update_url
          enclosure.attributes["length"] = @update_length
          enclosure.attributes["type"] = "application/zip"
        end

        def to_s
          formatter = REXML::Formatters::Pretty.new
          formatter.compact = true
          ret = ""
          formatter.write(@xml, ret)
          return ret
        end

      end
 
      def initialize(
          name: 'Screenhero', 
          language: 'en',
          publish_date: Time.now, 
          description: '',
          appcast_url: '',
          path: '')

        @name = name
        @version = version
        @language = language
        @publish_date = publish_date
        @description = description
        @appcast_url = appcast_url

        if path.empty? then
          @xml = REXML::Document.new
          generate_appcast_xml!
        else
          file = File.new(path)
          @xml = REXML::Document.new(file)
        end
      end
      attr_accessor :name, :version, :language, :publish_date, :description, :path

      def generate_appcast_xml!
        rss = @xml.add_element("rss")
        rss.attributes["xmlns:sparkle"] = "http://www.andymatuschak.org/xml-namespaces/sparkle"
        rss.attributes["xmlns:atom"] = "http://www.w3.org/2005/Atom"
        rss.attributes["xmlns:content"] = "http://purl.org/rss/1.0/modules/content/"
        rss.attributes["xmlns:wfw"] = "http://wellformedweb.org/CommentAPI/"
        rss.attributes["xmlns:dc"] = "http://purl.org/dc/elements/1.1/"
        rss.attributes["xmlns:sy"] = "http://purl.org/rss/1.0/modules/syndication/"
        rss.attributes["xmlns:slash"] = "http://purl.org/rss/1.0/modules/slash/"
        rss.attributes["xmlns:feedburner"] = "http://rssnamespace.org/feedburner/ext/1.0"
        rss.attributes["version"] = "2.0"

        channel = rss.add_element "channel"
        channel.add_element("title").add_text(@name)
        channel.add_element("description").add_text(@description)
        channel.add_element("language").add_text(@language)
        channel.add_element("pubDate").add_text(@publish_date.strftime("%a, %d %h %Y %H:%M:%S %z"))
        channel.add_element("link").add_text(@appcast_url)

        atom = channel.add_element("atom:link")
        atom.attributes["rel"] = "self"
        atom.attributes["type"] = "application/rss+xml"
        atom.attributes["href"] = @appcast_url
      end

      def add_item(version:, update_path:, update_url:, release_notes_url:"", author:"")
        @xml.elements["/rss/channel"] << Item.new(name: @name, update_path: update_path,
          version: version, author: author, release_notes_url: release_notes_url,
          update_url: update_url).xml
      end

      def add_xml_file(item)
        @xml.elements["/rss/channel"] << item.xml
      end

      def has_version(version)
        @xml.elements.each("/rss/channel/item") do |element| 
          if defined? element.version && element.version.text == version
            return true
          end
        end
        return false
      end

      def write(path:)
        output = ""
        @xml.write(output)
        doc = Nokogiri.XML(output) do |config|
          config.default_xml.noblanks
        end
        output = doc.to_xml(:indent => 2)
        File.open(path, "w"){|file| file.puts output}
      end

      def to_s
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        ret = %Q(<?xml version="1.0" encoding="UTF-8"?>\n)
        formatter.write(@xml, ret)
        return ret
      end
    end
  end
end
