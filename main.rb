require 'sinatra'
require 'erb'
require 'dm-core'
require 'dm-migrations'

require './account.rb'
require './user.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/gamblingsite1.db")

DataMapper.auto_upgrade!

configure :development do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/gamblingsite1.db")
end

configure :production do
  #DataMapper.setup(:default, "postgres://#{Dir.pwd}/gamblingsite.db")
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/gamblingsite1.db')
end


configure do
  enable :sessions     # set :sessions, true
  set :username, 'prashul'
  set :password, 'prashul'
end


#redirect /login
get '/login' do
  if session[:login]
    erb :home
  else
    erb :login
  end
end


# post Login Method
# verifying user crdentials from the data base
post '/login' do
    
     user_logged = params[:username]
     user_password = params[:password]
     session[:message] = nil
    #  User.first_or_create({:Username => 'prashul', :password => 'prashul'})
     @user = User.get(user_logged)
    
         if @user.nil? # if user enters invalid username
           session[:message] = "You must enter a Valid Username! ✌"
           redirect '/login'
         else
            if user_logged == @user.Username && user_password == @user.password #verifying user login with Database entries
                initialise_account(@user.Username)
                session[:login] = true
                session[:name] = user_logged        
                erb :home
            else
                session[:message] = "username and password does not match 👀"
                redirect '/login'
            end     
        end
      
end


get '/logout' do
    if session[:login]
      redirect '/logout'
    end
end

post '/logout' do

      username = session[:name]
      totalwin = session[:accountwin].to_i
      totalloss = session[:accountloss].to_i
      totalprofit = session[:accountprofit].to_i

      # if username == Account.all(:username.like => username).first.username
            #Updating if user entry already exists
            Account.first_or_create({:username => username.to_s}).update(totalwin: totalwin, totalloss: totalloss, totalprofit: totalprofit)
       #else
            #Inserting if user entry does not exist
           # Account.create(username: username.to_s, totalwin: totalwin, totalloss: totalloss, totalprofit: totalprofit)
      # end

       session.clear #clearing whole session everytime the user logs out
       redirect '/login'
end


#using form action post in home.erb to handle dynamic gambling on screen
post '/gamble/begins' do
  
    stake = params[:stake].to_i
    number = params[:number].to_i
    roll = rand(6) + 1
    session[:message] = nil

  if stake == 0 || number == 0
    session[:message] = "You must enter the Bet money and Bet number!!!<br>😉 😉 😉"
  else
    
      if number == roll
        session[:flag] = true
        win = 10*stake
        save_session(:win, win) #saving dynamic Win
        save_session(:accountwin, win) #saving dynamic Account Win
        session[:message] = "🎊Lucky You! you won #{win} Dollars 🎊<br> 🍻 Cheers 🍻  "
      else
        session[:flag] = false
        save_session(:lost, stake) #saving dynamic Loss
        save_session(:accountloss, stake )#saving dynamic Account Loss
        session[:message] = "☹  You lost #{stake} Dollars today. The dice landed on #{number} ☹  <br> Never Lose hope, you got good days ahead!"
      end
  end

  #Calculating user current gamble profit and overall profit of the user from first Login
  profit = session[:win].to_i - session[:lost].to_i
  accountprofit = session[:accountwin].to_i - session[:accountloss].to_i
  session[:profit] = profit.to_i
  session[:accountprofit] = accountprofit.to_i
  redirect '/login'
end


#session[:lost], session[:win]
#save_session(:lost, 1000)
#save_session(:win, 1000)
def save_session(won_lost, money)
  count = (session[won_lost] || 0).to_i
  count += money
  session[won_lost] = count
end


#Fetching Account details from DataBase and setting default for First Time users
def initialise_account(username)
        @useraccount = Account.get(username)
        if @useraccount.nil?
          session[:accountwin] = 0;
          session[:accountloss] = 0;
          session[:accountprofit] = 0;
        else
          session[:accountwin] = @useraccount.totalwin
          session[:accountloss] = @useraccount.totalloss
          session[:accountprofit] = @useraccount.totalprofit
        end
end