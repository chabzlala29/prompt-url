require 'open-uri'
require 'net/http'
require 'fileutils'
require 'nokogiri'
require 'pry'

class FetchUrl
  DEFAULT_FILE_EXT = 'html'.freeze

  OPTION_FLAGS = {
    metadata: '--metadata'
  }

  attr_reader :urls, :file_ext, :base_dir, :options, :metadata

  def initialize(urls: [], file_ext: DEFAULT_FILE_EXT, base_dir: Dir.pwd, options: {})
    @urls, @file_ext, @base_dir = urls, file_ext, base_dir
    @options = options

    generate_options!
    validate_urls!
  end

  def generate_html_files!
    @urls.map do |url|
      uri = URI.parse(url)

      filename = generate_domain_fname(uri)

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

  def generate_domain_fname(uri)
    # String#present? not existing on native ruby but empty does.
    merge_relative_path!(uri.host, uri) + '.html'
  end

  def merge_relative_path!(domain, uri)
    domain + uri.path.gsub(/\//, '_')
  end

  def calculate_stats(html_content:, uri:, filename:)
    doc = Nokogiri::HTML(html_content)

    stats = OpenStruct.new(
      links: doc.css('a'),
      images: doc.css('img'),
      domain: uri.host,
      filename: filename,
      last_fetched: Time.now.utc
    )

    if metadata
      puts "site: #{stats.domain}"
      puts "num_links: #{stats.links.size}"
      puts "images: #{stats.images.size}"
      puts "last_fetch: #{stats.last_fetched.strftime('%c')}"
    end

    stats
  end

  def generate_options!
    @metadata = options.include?(OPTION_FLAGS[:metadata])
  end

  def validate_urls!
    if urls.map { |url| !URI.parse(url).host.nil? }.include?(false)
      raise StandardError, "One of the URL is invalid."
    end
  end
end
