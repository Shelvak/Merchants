# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user = User.new(
  name: 'Admin',
  lastname: 'Admin',
  username: 'admin',
  email: 'admin@merchants.com',
  password: '123456',
  password_confirmation: '123456',
  role: :admin
)

puts(user.save ? 'User [OK]' : user.errors.full_messages.join("\n"))

