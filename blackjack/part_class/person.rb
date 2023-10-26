# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "./hands.rb"

class Person
  attr_reader :name, :state, :hands, :chip, :bets
  def initialize(name)
    @name = name
    @state = ""
    @hands = Hands.new
    @chip = 10000
    @bets = 0
    @action_count = 0
  end

  def bet(bet_amount)
    @bets = bet_amount
    @chip -= bet_amount
  end

  def double_down_bet
    @chip -= @bets
    @bets *= 2
  end

  def can_double_down?
    @action_count.zero? && chip >= bets
  end

  def initialize_person
    hands.clear_hand
    @action_count = 0
    @state = ""
    reset_bets
  end

  def show_points
    puts "#{name}の現在の所持ポイントは#{chip}です。"
  end

  def reset_bets
    @bets = 0
  end

  def add_chip_surrender
    add_chip((bets / 2).floor)
  end

  def add_chip_win
    add_chip(bets * 2)
  end

  def add_chip_draw
    add_chip(bets)
  end

  def add_chip(point)
    @chip += point
  end

  def decide_action
    if @hands.calculate_score < 17
      "Hit"
    else
      "Stand"
    end
  end

  def receive_card(card)
    @hands.add_card(card)

    puts "#{name}の引いたカードは#{card}です。"

    score = @hands.calculate_score

    if score > NUMBER_OF_BLACKJACK
      @state = "bust"

      puts "#{@name}はbustしました。"
    end

    sleep SLEEP_SECOND
  end

  def to_s
    "#{@name}: #{@state}"
  end

  def score_call
    puts "#{@name}の現在の得点は#{@hands.calculate_score}点です。"
  end

  def is_bust?
    hands.calculate_score > NUMBER_OF_BLACKJACK
  end
end
