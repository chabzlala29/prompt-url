require 'open-uri'
require 'net/http'
require 'fileutils'
require 'pry'

class FetchUrl
  DEFAULT_FILE_EXT = 'html'.freeze

  attr_reader :urls, :file_ext, :base_dir

  def initialize(urls: [], file_ext: DEFAULT_FILE_EXT, base_dir: Dir.pwd)
    @urls, @file_ext, @base_dir = urls, file_ext, base_dir

    validate_urls!
  end

  def generate_html_files!
    puts 'Generating HTML files of the following urls: '
    @urls.map do |url|
      uri = URI.parse(url)
      domain = if uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)
                 uri.host
               else
                 uri.to_s
               end
      url = "https://#{url}" unless uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)
      filename = domain + '.html'

      html_content = fetch_html_from_url(url)

      file_path = FileUtils.mkdir_p(base_dir).first

      File.open(file_path + "/#{filename}", 'w') do |file|
        file.puts html_content
      end

      puts "Generated HTML file for #{url}"

      filename
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
        if new_location
          puts "Following redirect to: #{new_location}"
          html_content = open(new_location).read
        else
          puts "No redirect location found."
        end
      else
        puts "Error fetching the URL: #{e.message}"
      end
    end

    html_content
  end

  def validate_urls!
  end
end
