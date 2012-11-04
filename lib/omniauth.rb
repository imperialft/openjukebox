require 'omniauth'
require 'omniauth-twitter'

module OmniAuth
  def self.setup(app)
    app.class_eval do
      enable :sessions
      use Builder do
        # Obtain this from here: https://dev.twitter.com/apps/3548274/show
        provider :twitter, 'ofa8iNrVBp2Wkm15fEMg', 'jv4Jm1XlMJWKPz9m88lqPruAeAk8vcYAuASQTBfwu8'
      end
      get '/auth/logout' do
        session[:id] = nil
        session[:token] = nil
        redirect '/'
      end
      get '/auth/:name/callback' do
        auth = request.env['omniauth.auth']
        unless user = User.first(:provider => auth.provider, :uid => auth.uid)
          user = User.create(:provider => auth.provider, :uid => auth.uid, :info => auth.info.to_hash)
        end
        token = user.new_token!
        session[:id] = user.id
        session[:token] = token
        redirect session.delete(:back) || '/'
      end
      helpers do
        def user
          @user ||= User.first(:id => session[:id], :token => session[:token]) if session[:id] && session[:token]
        end
        def signed_in?
          !!user
        end
        def require_user!
          unless signed_in?
            session[:back] = request.env['REQUEST_URI']
            redirect '/auth/twitter'
          end
        end
      end
    end
  end
end