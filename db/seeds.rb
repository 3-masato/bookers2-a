# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do |n|
  User.create!(
    email: "test#{n + 1}@test.com",
    name: "test user #{n + 1}",
    password: "testhoge"
  )
end

User.all.each do |user|
  5.times do |n|
    Book.create!(
      title: "test title #{n + 1}",
      body: "test body #{n + 1}",
      user_id: user.id
    )
  end
end