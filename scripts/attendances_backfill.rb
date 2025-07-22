# scripts/attendances_backfill.rb
# Eenmalig script om alle bestaande lopers als 'aanwezig' aan alle trainingen van hun groep toe te voegen

Group.includes(:users, training_schemas: :training_sessions).find_each do |group|
  group.users.each do |user|
    group.training_schemas.each do |schema|
      schema.training_sessions.each do |sessie|
        Attendance.find_or_create_by!(user: user, training_session: sessie) do |attendance|
          attendance.status = 'aanwezig'
        end
      end
    end
  end
end

puts 'Alle lopers zijn als aanwezig aangemeld voor alle trainingen van hun groep.' 