get '/' do
  @access_token = session[:auth]
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb
  if session[:auth]
    @access_token = session[:auth]
  else
    @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    # our request token is only valid until we use it to get an access token, so let's delete it from our session
    session.delete(:request_token)
    session[:auth] = @access_token
  end

  # at this point in the code is where you'll need to create your user account and store the access token
  @user = User.find_or_create_by_user_id(user_id: @access_token.params[:user_id])
  @user.update_attributes({username: @access_token.params[:screen_name],
                          oauth_token: @access_token.token,
                          oauth_secret: @access_token.secret})
  session[:user] = @user.id
  erb :index
end

post '/' do
  p params
  user = User.find(session[:user])
  client = Twitter::Client.new(:oauth_token => user.oauth_token, :oauth_token_secret => user.oauth_secret)
  client.update(params[:tweet])
  content_type :json
  {successful: "You have successfully tweeted!"}.to_json
end
