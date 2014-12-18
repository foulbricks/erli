if User.count < 2
  user = User.new
  user.first_name = "Matteo"
  user.last_name = "Palitto"
  user.email = "mpalitto@gmail.com"
  user.passwd = "lavitaebella"
  user.passwd_confirmation = "lavitaebella"
  user.admin = true
  user.active = true
  user.save
end