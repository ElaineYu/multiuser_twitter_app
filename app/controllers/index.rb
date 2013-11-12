get '/' do
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
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)
  puts @access_token
  # puts @access_token.inspect

  # at this point in the code is where you'll need to create your user account and store the access token
  current_user = User.find_or_create_by(username: @access_token.params[:screen_name], oauth_token: @access_token.params[:oauth_token], oauth_secret: @access_token.secret)
  session[:current_user] = current_user
  puts "%%%%%%%%%%%%%%%"
  puts session[:current_user]
  puts "%%%%%%%%%%%%%%%"
  erb :index
  
end

post '/post_to_twitter' do
  # session[:current_user] is the user object
   @twitter_user_name = session[:current_user].username
   puts @twitter_user_name

   # you can specify all configuration options when instantiating a Twitter::Client.new(...)
  current_twitter_user = Twitter::Client.new(
    # :oauth_token => "a user's access token",
    :oauth_token => session[:current_user].oauth_token,
    # :oauth_token_secret => "a user's access secret"
    :oauth_token_secret => session[:current_user].oauth_secret)

  # After configuration, send tweet to twitter
  current_twitter_user.update(params[:tweet])
  # Same thing as Twitter.update("I'm tweeting something!")

  # Create tweet in database
  @tweet = Tweet.create(tweet: params[:tweet])

  # Test
  # params[:tweet]
  @tweets = Tweet.all

  redirect to('/')
end
