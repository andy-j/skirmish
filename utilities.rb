# various utility functions - input, die rolling, etc.

def get_input
  case char = $win.getch
    when Curses::KEY_BACKSPACE
      $input_buffer.pop
      return nil

    when 10 || 13   # KEY_ENTER is numpad enter - this matches \n or \r
      input = $input_buffer.join
      $input_buffer = Array.new
      return input

    when /[[:print:]]/
      $input_buffer << char
      return nil

  end
end

def handle_input(input)
  if input.nil?
    return
  end

  input.chomp!
  print_line

  if input.length == 0
    print_line("Please enter a valid command. A list of commands is available by typing 'commands'.\n")
    return
  end

  matches = $COMMANDS.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  command = matches.first

  unless command.nil?
    return command[1].call($player, input)
  else
    print_line("\"#{input}\" is not a valid command. A list of commands is available by typing 'commands'.\n")
  end
end

def show_prompt(prompt=">")
  $win.setpos($win.cury, 0)
  $win.deleteln
  $win.addstr(prompt + " " + $input_buffer.join)
end

# receive input from user with optional string as prompt
def prompt_user(prompt=">")
  $win.addstr(prompt + " ")
  input = $win.getstr

  return input
end

def print_line(line = "")
  $win.addstr(line + "\n")
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
