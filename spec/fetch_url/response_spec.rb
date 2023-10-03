require 'rspec'
require 'fileutils'
require_relative '../../app/lib/fetch_url'

RSpec.describe 'FetchUrl' do
  let(:urls) { ['https://google.com', 'https://facebook.com', 'https://instagram.com'] }
  let(:base_dir) { "test_files" }
  let(:fetch_url) { FetchUrl.new(urls: urls, base_dir: base_dir) }
  let(:response) { fetch_url.generate_html_files! }
  let(:expected_result) { ['google.com.html', 'facebook.com.html', 'instagram.com.html'] }

  after do
    FileUtils.rm_rf(base_dir)
  end

  it 'should generate files' do
    expect(response).to eq ['google.com.html', 'facebook.com.html', 'instagram.com.html']

    expected_result.each do |file|
      expect(File.exists?(base_dir + "/#{file}"))
    end
  end

  context "when urls doesn't have http or https" do
    let(:urls) { ['google.com', 'https://facebook.com', 'https://instagram.com'] }

    it 'should still generate those files' do
      expect(response).to eq expected_result

      expected_result.each do |file|
        expect(File.exists?(base_dir + "/#{file}"))
      end
    end
  end
end
