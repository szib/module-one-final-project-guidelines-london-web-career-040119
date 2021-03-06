# ========================================
#		Seeding database with Faker
# ========================================

def seed_with_faker
  Faker::Config.random = Random.new(42)
  Faker::Config.locale = 'en-GB'

  num_of_guests = 10
  num_of_events = 40
  num_of_attendance = 40

  num_of_guests.times { Guest.create(name: Faker::Name.unique.first_name) }

  num_of_events.times do
    Event.create(
      title: "#{Faker::Verb.ing_form} event",
      description: Faker::Lorem.sentences(3).join(' '),
      date: Faker::Date.forward(30),
      venue: Faker::Address.full_address,
    )
  end

  num_of_attendance.times do |_idx|
    extra_guest_is_coming = rand(1..4) % 4 == 0
    Attendance.create(
      guest: Guest.find(rand(1..num_of_guests)),
      event: Event.find(rand(1..num_of_events)),
      num_of_extra_guests: extra_guest_is_coming ? rand(1..5) : 0
    )
  end
end
