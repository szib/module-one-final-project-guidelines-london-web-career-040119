class CLI
  def initialize
    @pastel = Pastel.new
    @prompt = TTY::Prompt.new

    @app_name = 'Eventy'
  end

  def display_logo
    font = TTY::Font.new('doom')
    title = font.write(@app_name)
    puts @pastel.yellow(title)
  end

  def find_or_create_user
    name = @prompt.ask("What's your name?: ")
    @guest = Guest.find_or_create_by(name: name)
  end

  def welcome
    puts "Welcome, #{@guest.name}!"
  end

  def display_current_events
    puts 'You are currently attending:'
    @guest.events.each do |event|
      puts event.name
    end
    # add table @table = TTY::Table.new
  end

  # def add_event
  #   @prompt.yes?("Would you like to add another event?")
  # attendances

  # def add_event_name
  #   event_name = @prompt.ask("What's event name?")
  #   event = Event.find_or_create_by(name: event)
  #   Event.create(admin: @admin, guest: guest)
  #   puts "Done. You've created a new event."
  # end
  #
  # def bye
  #   puts "Okay, no worries!"
  # end

  def run
    display_logo
    find_or_create_user
    welcome
    display_current_events
    add_event
    # if add_event?
    #   add_event_name
    # else
    #   bye
    # end
  end
end