require 'bundler/setup'
require 'sinatra/base'

# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraStaticServer < Sinatra::Base

  before do
    redirect request.url.sub(/www\./, ''), 301 if request.host =~ /^www/
  end

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_file(File.join(File.dirname(__FILE__), 'public', '404.html'), {:status => 404})
  end

  def send_sinatra_file(path, &missing_file_block)
    original_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path_candidates = []
    file_path_candidates << original_path
    file_path_candidates << File.join(original_path, 'index.html')
    file_path_candidates << "#{original_path}.html"
    found_file_path = file_path_candidates.detect do |file_path|
      File.exist?(file_path) && !File.directory?(file_path)
    end || missing_file_block.call
    send_file(found_file_path)
  end

end

run SinatraStaticServer
