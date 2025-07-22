namespace :users do
  desc 'Genereer public_token en slug voor alle users waar deze ontbreken'
  task generate_public_tokens: :environment do
    User.where(public_token: [nil, '']).find_each do |user|
      user.update!(public_token: SecureRandom.hex(16))
      puts "Token gegenereerd voor #{user.name} (#{user.id})"
    end
    User.where(slug: [nil, '']).find_each do |user|
      user.update!(slug: user.name.to_s.parameterize)
      puts "Slug gegenereerd voor #{user.name} (#{user.id})"
    end
    puts 'Klaar.'
  end
end 