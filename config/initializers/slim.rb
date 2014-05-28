p ENV['SECRET_KEY_BASE']
p ENV['FBM_ROOT_URL']
p "HELLO??"

Slim::Engine.set_default_options :attr_delims => {'(' => ')', '[' => ']'}

Rails.application.assets.register_engine('.slim', Slim::Template)
