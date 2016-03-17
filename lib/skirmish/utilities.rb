# various utility functions - input, die rolling, etc.

class Command_History
  def initialize
    @history = Array.new
    @position = 0
  end

  def add_command(command)
    @history.push command
    @position = @history.length - 1
  end

  def get_last
    unless @position == 0
      last_command = @history[@position].split
      @position -= 1
      return last_command
    else
      return nil
    end
  end

  def get_next
    unless @position == @history.length - 1
      @position += 1
      next_command = @history[@position].split
      return next_command
    else
      return nil
    end
  end
end

def get_input
  case char = $win.getch
    when Curses::KEY_BACKSPACE
      $input_buffer.pop
      return nil

    when Curses::KEY_UP
      last_command = $command_history.get_last
      unless last_command.nil?
        $input_buffer = Array.new
        last_command.each { |chr|  $input_buffer.push chr }
      end
      return nil

    when Curses::KEY_DOWN
      next_command = $command_history.get_next
      unless next_command.nil?
        $input_buffer = Array.new
        next_command.each { |chr|  $input_buffer.push chr }
      end
      return nil

    when 10 || 13   # KEY_ENTER is numpad enter - this matches \n or \r
      input = $input_buffer.join
      $input_buffer = Array.new
      $command_history.add_command input
      return input

    when /[[:print:]]/  # add printable characters to our input buffer
      $input_buffer << char
      return nil

  end
end

def setup_screen
  Curses.init_screen
  Curses.start_color
  Curses.cbreak
  Curses.noecho
  Curses.nl

  Curses.init_pair(1, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
  Curses.init_pair(2, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
  Curses.init_pair(3, Curses::COLOR_WHITE, Curses::COLOR_BLACK)

  $win = Curses::Window.new(0, 0, 0, 0)
  $win.color_set(1)
  $win.scrollok true
  $win.idlok true
  $win.keypad = true
end

def handle_input(input)
  if input.nil?
    return
  end

  input.chomp!
  $win.addstr("\n\n")

  if input.length == 0
    print_line("Please enter a valid command. A list of commands is available by typing 'commands'.\n")
    return
  end

  matches = $commands.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  command = matches.first

  unless command.nil?
    return command[1].call($player, input)
  else
    print_line("\"#{input}\" is not a valid command. A list of commands is available by typing 'commands'.\n")
  end
end

def show_prompt(prompt=">")
  $win.color_set(3)
  $win.setpos($win.cury, 0)
  $win.deleteln
  $win.addstr(prompt + " " + $input_buffer.join)
  $win.color_set(1)
end

def print_line(line = "", color = :green)
  case color
  when :green
    $win.color_set(1)
  when :cyan
    $win.color_set(2)
  when :white
    $win.color_set(3)
  end

  $win.setpos($win.cury, 0)
  $win.deleteln
  $win.addstr(line + "\n")

  $win.color_set(1)
end

def roll_dice(number_of_dice, size_of_dice)
  roll = 0
  i = 0

  until i == number_of_dice do
    roll += rand(1..size_of_dice)
    i += 1
  end

  roll
end
