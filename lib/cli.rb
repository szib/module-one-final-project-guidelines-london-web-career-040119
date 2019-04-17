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

  def bye
    font = TTY::Font.new('doom')
    title = font.write("Bye")
    puts @pastel.yellow(title)
  end

  def message(msg)
    puts @pastel.cyan("\n==> #{msg}\n")
  end

  def find_or_create_user
    name = @prompt.ask("What's your name?: ")
    @guest = Guest.find_or_create_by(name: name)
  end

  def welcome
    puts "Welcome, #{@guest.name}!"
  end

  def show_menu
    menu_items = ['Show my events', 'Manage my events', 'Find new events', 'Quit']
    @prompt.select('What would you like to do?', menu_items)
  end

  def display_current_events
    puts 'You are currently attending:'
    tp @guest.reload.events, :title, :date, :venue
  end

  def select_new_event
    events = @guest.reload.new_events
    choices = Event.to_menu_items(events)
    id = @prompt.select('Select an event to continue:', choices, filter: true)
    Event.find(id)
  end

  def select_my_event
    events = @guest.reload.events
    choices = Event.to_menu_items(events)
    id = @prompt.select('Select an event to continue:', choices, filter: true)
    Event.find(id)
  end

  def sign_up?(event)
    question = "Would you like to attend this event?"
    answer = @prompt.yes?(question)
  end

  def cancel?(event)
    question = "Would you like to cancel your attendance?"
    answer = @prompt.yes?(question)
  end

  def update_friends(event)
    return unless event.attending?(@guest)

    attendance = Attendance.find_by(guest: @guest, event: event)

    question = "You are bringing #{attendance.friends_to_s}. Would you like to change it?"
    answer = @prompt.yes?(question)

    if answer == true
      question = "How many friends would you like to bring?"
      answer = @prompt.ask(question) do |q|
        q.validate /^\d$/
        q.messages[:valid?] = 'You can bring up to nine friends.'
      end
      attendance.change_num_of_friends(answer.to_i)
      message("Consider it done.")
    else
      message("Okay, no problem!")
    end
  end

  def display_guest_list(event)
    pastel = Pastel.new
    attendees = event.attendances.first(5).map { |a| a.guest_name_with_friends }.join(", ")
    if event.attendances.length > 5
      attendees = [attendees, " and many more..."].join()
    end

    puts pastel.green("-" * 60)
    puts pastel.green("Guest list:")
    puts pastel.green(attendees)
    puts pastel.green("-" * 60)
  end

  def display_event(event)
    pastel = Pastel.new
    puts '-' * 60
    puts pastel.yellow(event.title)
    puts '-' * 60

    puts pastel.cyan("Description:\t\t #{event.description}")
    puts pastel.cyan("Date:\t\t #{event.date}")
    puts pastel.cyan("Venue:\t\t #{event.venue}")
    puts pastel.cyan("Attendees:\t\t #{event.num_of_attendees}")

    display_guest_list(event)
  end

  def search_menu
    choices = ["Sign up for this event.", "Back"]
    @prompt.select("Choose from the menu:", choices)
  end

  def manage_menu
    choices = ["Cancel attendance.", "Change extra guests", "Back"]
    @prompt.select("Choose from the menu:", choices)
  end

  def find_new_events
    event = select_new_event
    display_event(event)

    menu_item = search_menu

    case menu_item
    when "Sign up for this event."
      if sign_up?(event)
        event.toggle_attendance(@guest)
        message("Consider it done.")
      else
        message("Okay, no problem.")
      end
    else
      puts "Going back!"
    end
  end

  def manage_my_events
    event = select_my_event
    display_event(event)

    menu_item = manage_menu

    case menu_item
    when "Cancel attendance."
      if cancel?(event)
        event.toggle_attendance(@guest)
        message("Consider it done.")
      else
        message("Okay, no problem.")
      end
    when "Change extra guests"
      update_friends(event)
    else
      message("Going back!")
    end
  end

  def run
    display_logo
    find_or_create_user
    welcome

    answer = nil
    until answer == 'Quit'
      answer = show_menu
      case answer
      when 'Show my events'
        display_current_events
      when 'Manage my events'
        manage_my_events
      when 'Find new events'
        find_new_events
      end
    end

    bye
  end
end
