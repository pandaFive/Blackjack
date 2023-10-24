# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "../person.rb"

class Player < Person
  def initialize
    super("あなた")
  end

  def decide_action
    puts "#{@name}の現在の得点は#{@hands.calculate_score}です。カードを引きますか？：(y/n)"
    decide = gets.chomp

    while decide != "y" && decide != "n"
      puts "yかnを入力してください。："
      decide = gets.chomp
    end

    if decide == "y"
      "Hit"
    else
      "Stand"
    end
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
end
