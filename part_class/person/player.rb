# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "../person.rb"

class Player < Person
  def initialize
    super("あなた")
  end

  def bet
    sleep SLEEP_SECOND
    puts "1~#{chip}の範囲で賭けるポイントを入力してください："
    bet_amount = gets.chomp.to_i

    while bet_amount < 1 || bet_amount > chip
      puts "1~#{chip}の範囲で賭けるポイントを入力してください："
      bet_amount = gets.chomp.to_i
    end
    @chip -= bet_amount
    @bets = bet_amount
  end

  def decide_action
    available_options = get_available_options
    puts "#{@name}の現在の得点は#{@hands.calculate_score}です。行動を選択してください(#{ available_options.join("/") })："
    decide = gets.chomp

    while !action_validator(decide)
      puts "次の選択肢の中から入力してください。(#{available_options.join("/")})："
      decide = gets.chomp
    end

    @action_count += 1

    @state = decide

    decide
  end

  def receive_card(card)
    @hands.add_card(card)

    puts "#{@name}が引いたカードは#{card}です。"

    score = @hands.calculate_score

    if score > NUMBER_OF_BLACKJACK
      @state = "bust"

      puts "#{@name}はbustしました。"
    end

    sleep SLEEP_SECOND
  end

  private
    def get_available_options
      actions = ["Hit", "Stand"]
      actions.push("Surrender") if @action_count.zero?
      actions.push("Double Down") if can_double_down?
      actions
    end

    def action_validator(input)
      get_available_options.include?(input)
    end
end
