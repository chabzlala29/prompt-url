require 'open-uri'
require 'net/http'
require 'fileutils'
require 'nokogiri'
require 'pry'

class FetchUrl
  DEFAULT_FILE_EXT = 'html'.freeze

  attr_reader :urls, :file_ext, :base_dir

  def initialize(urls: [], file_ext: DEFAULT_FILE_EXT, base_dir: Dir.pwd)
    @urls, @file_ext, @base_dir = urls, file_ext, base_dir

    validate_urls!
  end

  def generate_html_files!
    @urls.map do |url|
      uri = URI.parse(url)

      domain = if uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)
                 uri.host
               else
                 uri.to_s
               end

      # String#present? not existing on native ruby but empty does.
      domain = merge_relative_path!(domain, uri)

      url = "https://#{url}" unless uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)

      filename = domain + '.html'

      html_content = fetch_html_from_url(url)

      file_path = FileUtils.mkdir_p(base_dir).first

      File.open(file_path + "/#{filename}", 'w') do |file|
        file.puts html_content
      end

      calculate_stats(
        html_content: html_content,
        uri: uri,
        filename: filename
      )
    end
  end

  private

  def fetch_html_from_url(url)
    html_content = nil

    begin
      html_content = open(url).read
    rescue OpenURI::HTTPError => e
      if e.message =~ /^301/
        # The URL has been moved permanently; get the new location
        new_location = e.io.meta['location']
        html_content = open(new_location).read if new_location
      end
    end

    html_content
  end

  def merge_relative_path!(domain, uri)
    if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      domain + uri.path.gsub(/\//, '_')
    else
      domain.gsub(/\//, '_')
    end
  end

  def calculate_stats(html_content:, uri:, filename:)
    doc = Nokogiri::HTML(html_content)

    OpenStruct.new(
      links: doc.css('a'),
      images: doc.css('img'),
      domain: uri.host,
      filename: filename
    )
  end


  def validate_urls!
  end
end
