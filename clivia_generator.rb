require "terminal-table"
require "httparty"
require "htmlentities"
require "json"
require_relative "presenter"
require_relative "requester"

class CliviaGenerator
  include Presenter
  include Requester

  def initialize
    input = ARGV.shift
    @filename = input.nil? ? "scores.json" : input
    @questions = []
    @user_score = 0
  end

  def start
    print_welcome
    action = ""
    until action == "exit"
      action = select_main_menu_action
      case action
      when "random" then random_trivia
      when "scores" then print_scores
      when "exit" then puts "Thanks for using CLIvia Generator"
      end
    end
  end

  def random_trivia
    @questions = load_questions
    ask_questions
    print_welcome
  end

  def ask_questions
    @questions.each do |question|
      response = ask_question(question)
      if response == question[:correct_answer]
        puts "#{response}... Correct!"
        @user_score += 10
      else
        puts "#{response}... Incorrect!"
        puts "The correct answer was: #{question[:correct_answer]}"
      end
    end
    print_score(@user_score)
    data = will_save?(@user_score)
    save(data) unless data.nil?
    @user_score = 0
  end

  def save(data)
    scores = parse_scores
    scores.push(data)
    File.write(@filename, scores.to_json)
  end

  def parse_scores
    File.open(@filename, "a+") do |f|
      f.write("[]") if f.read == ""
    end

    JSON.parse(File.read(@filename), { symbolize_names: true })
  end

  def load_questions
    response = HTTParty.get("https://opentdb.com/api.php?amount=10")
    parse_questions(response)
  end

  def parse_questions(response)
    questions = JSON.parse(response.body, symbolize_names: true)
    questions = questions[:results]
    coder = HTMLEntities.new
    questions.map do |question|
      question[:category] = coder.decode(question[:category])
      question[:type] = coder.decode(question[:type])
      question[:difficulty] = coder.decode(question[:difficulty])
      question[:question] = coder.decode(question[:question])
      question[:correct_answer] = coder.decode(question[:correct_answer])
      question[:incorrect_answers] = question[:incorrect_answers].map do |item|
        coder.decode(item)
      end
      question
    end
  end

  def print_scores
    scores = parse_scores.sort_by { |hash| hash[:score] }
    scores.reverse!
    table = Terminal::Table.new
    table.title = "Top Scores"
    table.headings = ["Name", "Score"]
    table.rows = scores.map do |score|
      [score[:name], score[:score]]
    end
    puts table
    print_welcome
  end
end

trivia = CliviaGenerator.new
trivia.start
