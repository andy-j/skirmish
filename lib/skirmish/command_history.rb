class Command_History
  def initialize
    @history = Array.new
    @position = 0
  end

  def add_command(command)
    @history.push command
    @position = @history.length - 1
  end
  def get_previous
    unless @position == 0
      previous_command = @history[@position]
      @position -= 1
      previous_command
    else nil
    end
  end
  def get_last
    unless @position == 0
      last_command = @history[@position].split(/(\W)/)
      @position -= 1
      return last_command
    else
      return nil
    end
  end

  def get_next
    unless @position == @history.length - 1
      @position += 1
      next_command = @history[@position]
      return next_command
    else
      return nil
    end
  end
end