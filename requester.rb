module Requester
  def select_main_menu_action
    prompt = "random | scores | exit"
    options = prompt.split(" | ")

    gets_option(prompt, options)
  end

  def ask_question(question)
    puts "Category: #{question[:category]}"
    puts "Question: #{question[:question]}"
    options = []
    options.push(question[:correct_answer])
    question[:incorrect_answers].each { |option| options.push(option) }
    options.shuffle!
    options_id = (1..options.size).to_a
    answer_id = gets_option(question_options(options), options_id)
    options[answer_id - 1]
  end

  def will_save?(score)
    prompt = "Do you want to save your score? (y/n)"
    options = ["y", "Y", "n", "N"]
    action = gets_option(prompt, options)
    case action.downcase
    when "y"
      puts "Type the name to assign to the score"
      print "> "
      input = gets.chomp
      name = input == "" ? "Anonymous" : input
      { name: name, score: score }
    when "n"
      nil
    end
  end

  def gets_option(prompt, options)
    puts prompt
    action = ""
    loop do
      print "> "
      action = gets.chomp
      action = action.to_i if action.match(/^\d+$/) && action.to_i.positive?
      break if options.include?(action)

      puts "Invalid option"
    end
    action
  end

  # Auxiliar methods

  def question_options(options)
    formated_options = []
    options.each do |option|
      formated_option = "#{options.index(option) + 1}. #{option}"
      formated_options.push(formated_option)
    end
    formated_options.join("\n")
  end
end
