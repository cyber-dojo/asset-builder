# frozen_string_literal: true

# k8s/curl probing + identity
class Prober
  def initialize(externals)
    @externals = externals
  end

  def alive?(_args)
    true
  end

  def ready?(_args)
    true
  end

  def sha(_args)
    ENV.fetch('SHA', nil)
  end

end
