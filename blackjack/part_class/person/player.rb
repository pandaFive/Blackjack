# frozen_string_literal: true

require_relative "../../../config/application.rb"
require_relative "../person.rb"

class Player < Person
  def initialize
    super("あなた")
  end

  def bet
    sleep SLEEP_SECOND
    puts "1~#{@chip}の範囲で賭けるポイントを入力してください："
    bet_amount = gets.chomp.to_i

    while bet_amount < 1 || bet_amount > @chip
      puts "1~#{@chip}の範囲で賭けるポイントを入力してください："
      bet_amount = gets.chomp.to_i
    end
    @chip -= bet_amount
    @hands.bet(bet_amount)
  end

  def create_action_message
    message = if @hands_array.length >= 2
      "#{@name}の#{@hands_array.index(@hands) + 1}つ目の手札"
    else
      "#{@name}"
    end
    message += "の現在の得点は#{@hands.calculate_score}です。行動を選択してください(#{get_available_options.join("/")})："

    message
  end

  def decide_action
    available_options = get_available_options
    puts create_action_message
    decide = gets.chomp

    while !action_validator(decide)
      puts "次の選択肢の中から入力してください。(#{available_options.join("/")})："
      decide = gets.chomp
    end

    hands.state = decide

    decide
  end

  private
    def get_available_options
      actions = ["Hit", "Stand"]
      actions.push("Surrender") if can_surrender?
      actions.push("Double Down") if can_double_down?
      actions.push("Split") if can_split?
      actions
    end

    def action_validator(input)
      get_available_options.include?(input)
    end
end
