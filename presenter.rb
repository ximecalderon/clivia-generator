module Presenter
  def print_welcome
    puts "###################################"
    puts "#   Welcome to Clivia Generator   #"
    puts "###################################"
  end

  def print_score(score)
    puts "Well done! Your score is #{score}"
    puts("-" * 50)
  end
end
