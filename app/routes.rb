module Vitos
  module Routes
    # autoload :Assets, 'app/routes/assets'
    autoload :Base, 'app/routes/base'
    autoload :Static, 'app/routes/static'

    # Other routes:
    autoload :Nav, 'app/routes/nav'
    autoload :API, 'app/routes/api'
    autoload :Test, 'app/routes/test'
    autoload :Ordering, 'app/routes/ordering'
    autoload :Account, 'app/routes/account'
  end
end