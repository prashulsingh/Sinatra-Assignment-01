

require 'sinatra'
require 'erb'
require './account.rb'

@win = 0
@loss = 0
@profit = 0


get '/bet/:stake/on/:number' do
  stake = params[:stake].to_i
  number = params[:number].to_i
  roll = rand(6) + 1
  if number == roll
    "The dice landed on #{roll}, you win #{10*stake} dollars"
  else
    save_session(:lost, stake)
    %{The dice landed on #{roll}, you lost #{stake} dollars,
      total lost is #{session[:lost]} dollars}
  end
end

#session[:lost], session[:win]
#save_session(:lost, 1000)
#save_session(:win, 1000)
def save_session(won_lost, money)
  count = (session[won_lost] || 0).to_i
  count += money
  session[won_lost] = count
end

