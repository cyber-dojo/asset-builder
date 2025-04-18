# frozen_string_literal: true

require 'English'

require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require 'json'
require 'sprockets'
require 'uglifier'

class AppBase < Sinatra::Base
  def initialize(externals)
    @externals = externals
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV.fetch('PORT', nil)
  set :environment, Sprockets::Environment.new

  environment.append_path('app/assets/stylesheets')
  environment.css_compressor = :sassc

  get '/assets/app.css', provides: [:css] do
    respond_to do |format|
      format.css do
        env['PATH_INFO'].sub!('/assets', '')
        settings.environment.call(env)
      end
    end
  end

  environment.append_path('app/assets/javascripts')
  environment.js_compressor = Uglifier.new(harmony: true)

  get '/assets/app.js', provides: [:js] do
    respond_to do |format|
      format.js do
        env['PATH_INFO'].sub!('/assets', '')
        settings.environment.call(env)
      end
    end
  end

  def self.get_delegate(klass, name)
    get "/#{name}", provides: [:json] do
      respond_to do |format|
        format.json do
          target = klass.new(@externals)
          result = target.public_send(name, params)
          json({ name => result })
        end
      end
    end
  end

  set :show_exceptions, false

  error do
    error = $ERROR_INFO
    status(500)
    content_type('application/json')
    info = {
      exception: {
        request: {
          path: request.path,
          body: request.body.read
        },
        backtrace: error.backtrace
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        path: error.path,
        args: error.args,
        name: error.name,
        body: error.body,
        message: error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = JSON.pretty_generate(info)
    puts diagnostic
    body diagnostic
  end
end
