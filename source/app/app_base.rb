# frozen_string_literal: true

require 'English'

require 'sinatra/base'
require 'json'
require 'sassc-embedded'
require 'sprockets'
require 'uglifier'

class AppBase < Sinatra::Base
  def initialize(externals)
    @externals = externals
    super(nil)
  end

  set :port, ENV.fetch('PORT', nil)
  set :environment, Sprockets::Environment.new

  environment.append_path('app/assets/stylesheets')
  environment.css_compressor = :sassc

  get '/assets/app.css', provides: [:css] do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  environment.append_path('app/assets/javascripts')
  environment.js_compressor = Uglifier.new(harmony: true)

  get '/assets/app.js', provides: [:js] do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  def self.get_delegate(klass, name)
    get "/#{name}", provides: [:json] do
      target = klass.new(@externals)
      result = target.public_send(name, params)
      JSON.generate({ name => result })
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
