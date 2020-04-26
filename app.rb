require 'sinatra'
require 'slim'
require "sqlite3"
require "bcrypt"

enable :sessions


#arrays för notes och users
rt2 = []
users = []



#Funktion som finns på varje sida, den kollar om användaren är inloggad. Ifall inte så redirect("/loggedoff")
def loggedin()
  if session["username"] == nil 
      redirect("/loggedoff")
  end
end


#Funktion för login-sida
#Den kollar så att kontot finns, och om lösenordet är rätt. 
def accountexist()
  session["users"].each do |user|
    if user[:username] == params["username"] && user[:password] == params["password"]
      session["username"] = params["username"]
      session["password"] = params["password"]
      redirect("/")
    elsif user[:username] == params["username"] && user[:password] != params["password"]
      session["error"] = "Fel lösenord"
      redirect("/error")
  end
  end
end


#Errorsida
get("/error") do 
  slim(:error)
end

#Loginsida
post("/login") do
  accountexist()
end



#Startsida
get('/') do
  loggedin()
  slim(:index)
end

#Sida för att ändra användarnamn
get("/user") do
  loggedin()
  slim(:user)
end

#Sida där man loggar in och registrerar sig. 
get("/loggedoff") do
  session["username"] = nil
  session["password"] = nil
  slim(:loggedoff)
end

#Funktion som kollar ifall användarnamnet till ett nytt konto är upptaget. 
def register()
  session["users"].each do |user|
    if params["usernamereg"] == user[:username] 
      session["error"] = "Detta användarnamnet är upptaget"
      redirect("/error")
    else 
    end
  end
end



#Formulär för registrering
post("/register") do
  session["user_hash"] = {
  :username => "",
  :password => ""
  }
  if params["usernamereg"] == ""|| params["passwordreg"] == ""
    session["error"] = "Du måste ha ett användarnamn och ett lösenord!"
    redirect("/error")
  end
  session["user_hash"][:username] = params["usernamereg"]
  session["user_hash"][:password] = params["passwordreg"]
  session["username"] = params["usernamereg"]
  session["password"] = params["passwordreg"]
  session["users"] = users
  register()
  users << session["user_hash"]
  redirect("/loggedoff")
end

#Formulär för att ändra användarnamn
post("/user/change") do
  session["users"].each do |user|
    if user[:username] == session["username"]
      session["username"] = params["ny_namn"]
      user[:username] = params["ny_namn"]
      users = session["users"] 
      redirect("/")
    elsif session["username"] == nil
       redirect("/loggedoff")
    end
  end
end

#Visa formulär som lägger till en note
get('/notes/new') do
  loggedin()
  slim(:"notes/new")
end


#Skapa note
post('/notes/create') do
    session["rt"] = {
      :rubrik => "",
      :notes => "",
      :user => session["username"]
    }
 
    session["rt"][:rubrik] = params["ny_rubrik"]
    session["rt"][:notes] = params["ny_note"]

    rt2 << session["rt"]
    session["rt2"] = rt2
    redirect('/notes')
end

#Visa alla notes
get('/notes') do
  loggedin()
  slim(:"notes/show")
end

#Delete-sida
get("/delete") do
  loggedin()
  slim(:delete)
end

#Formulär som tar bort alla notes
post("/delete/all") do
  session["rt2"] = []
  redirect("/notes")
end