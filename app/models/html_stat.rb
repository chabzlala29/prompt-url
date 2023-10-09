require 'nokogiri'

class HtmlStat
  attr_reader :links,
              :images,
              :domain,
              :filename,
              :html_content,
              :uri,
              :last_fetched_at,
              :show_metadata

  def initialize(html_content:, uri:, filename:, show_metadata: false)
    @html_content, @uri, @filename = html_content, uri, filename
    @show_metadata = show_metadata
  end

  def calculate
    populate_links_and_images
    populate_domain
    populate_last_fetched_at

    log_stat if show_metadata

    self
  end

  def last_fetched
    @last_fetched ||= last_fetched_at.strftime('%c')
  end

  private

  def doc
    @doc ||= Nokogiri::HTML(html_content)
  end

  def populate_links_and_images
    @links = doc.css('a')
    @images = doc.css('img')
  end

  def populate_domain
    @domain = uri.host
  end

  def populate_last_fetched_at
    @last_fetched_at = Time.now.utc
  end

  def log_stat
    puts "site: #{domain}"
    puts "num_links: #{links.size}"
    puts "images: #{images.size}"
    puts "last_fetch: #{last_fetched}"
    puts "\n"
  end
end
