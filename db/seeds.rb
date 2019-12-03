# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = []
posts = []
comments = []

# create 10 users, each with 10 posts
10.times do
  u = User.create!(
    email: Faker::Internet.unique.email,
    password: '123456'
  )
  users.push(u.id)

  10.times do
    p = Post.create!(
      user_id: u.id,
      title: Faker::TvShows::SiliconValley.quote,
      body: Faker::Hipster.paragraph(sentence_count: 5),
      latitude: rand(33.69..34.12),
      longitude: rand(-118.55..-118.08)
    )
    posts.push(p.id)
  end
end

# create 200 random comments across all posts
200.times do
  c = Comment.create!(
    user_id: users.sample,
    post_id: posts.sample,
    body: Faker::Lorem.sentence(word_count: 8)
  )
  comments.push(c.id)
end

# TODO: likes
