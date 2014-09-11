module Vitos
  module Routes
    class Assets < Base
      get '/assets/*' do
        env['PATH_INFO'].sub!(%r{^/assets}, '')
        # puts(env)
        settings.assets.call(env)
      end
    end
  end
end