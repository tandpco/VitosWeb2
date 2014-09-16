require 'digest/md5'
module Vitos
  module Routes
    class Test < Base
      get '/test-signup' do
        slim :signup
      end
      get '/test-pay' do
        slim :testpay
        # @TODO: Get test card data from @thomas so we can run the payment process [github.com/tandpco/VitosWeb2/issues/1]
      end
      post '/test-pay-return' do
        # @TODO: Verify payment token information being returned and apply to order [github.com/tandpco/VitosWeb2/issues/2]
        # @TODO: Verify all other payment methods and gift cards work [github.com/tandpco/VitosWeb2/issues/3]
        json params.to_hash
      end
    end
  end
end