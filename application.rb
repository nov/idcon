require 'bundler/setup'
require 'sinatra/base'

# The project root directory
$root = ::File.dirname(__FILE__)

class Application < Sinatra::Base
  before    { unify_hostname }
  not_found { send_file absolute('404.html'), status: 404 }

  get(/.+/) do
    respond_with_static_file request.path
  end

  private

  def unify_hostname
    alternate_domains = [
      'www.idcon.org',
      'idcon.herokuapp.com'
    ]
    if alternate_domains.include?(request.host)
      redirect request.url.sub(request.host, 'idcon.org')
    end
  end

  def respond_with_static_file(path)
    if file_path = static_file_for(path)
      expires 600, :public
      send_file file_path
    else
      404
    end
  end

  def static_file_for(path)
    original_path = absolute path
    file_path_candidates = [original_path]
    unless original_path =~ /\.html$/
      file_path_candidates << File.join(original_path, 'index.html')
      file_path_candidates << "#{original_path}.html"
    end
    file_path_candidates.detect do |file_path|
      File.exist?(file_path) && !File.directory?(file_path)
    end
  end

  def absolute(path)
    File.join File.dirname(__FILE__), 'public',  path
  end
end
