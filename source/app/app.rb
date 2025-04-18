# frozen_string_literal: true

require_relative 'app_base'
require_relative 'prober'

class App < AppBase
  def initialize(externals)
    super(externals)
    @externals = externals
  end

  attr_reader :externals

  get_delegate(Prober, :alive?)
  get_delegate(Prober, :ready?)
  get_delegate(Prober, :sha)

end
