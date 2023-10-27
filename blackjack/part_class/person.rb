# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "./hands.rb"

class Person
  attr_reader :name, :hands, :chip, :hands_array
  def initialize(name)
    @name = name
    @hands = Hands.new
    @hands_array = [@hands]
    @chip = 10000
  end

  def bet(bet_amount)
    @hands.bet(bet_amount)
    @chip -= bet_amount
  end

  def double_down_bet
    @chip -= @hands.bets
    @hands.double_down_bet
  end

  def can_double_down?
    @hands.length == 2 && @chip >= @hands.bets
  end

  def can_surrender?
    @hands_array.length == 1 && hands.length == 2
  end

  def can_split?
    @hands.can_split? && can_double_down?
  end

  def initialize_person
    @hands = Hands.new
    @hands_array = [@hands]
  end

  def show_points
    puts "#{name}の現在の所持ポイントは#{@chip}です。"
  end

  def add_chip_surrender
    add_chip((@hands.bets / 2).floor)
  end

  def add_chip_win
    add_chip(@hands.bets * 2)
  end

  def add_chip_draw
    add_chip(@hands.bets)
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
      @hands.state = "bust"

      puts "#{@name}はbustしました。"
    end

    sleep SLEEP_SECOND
  end

  def switching_hands
    return if @hands_array.length == 1
    current_index = @hands_array.index(@hands)
    if current_index == @hands_array.length - 1
      @hands = @hands_array[0]
    else
      @hands = @hands_array[current_index + 1]
    end
  end

  def to_s
    "#{@name}: #{@state}"
  end

  def split_hands
    new_hands = Hands.new
    @hands_array.push(new_hands)
    new_hands.add_card(@hands.pop_card)
    new_hands.bet(@hands.bets)
    @chip -= new_hands.bets
  end

  def get_hands_index
    @hands_array.index(@hands)
  end

  def hands_number
    @hands_array.length
  end

  def score_call
    puts "#{@name}の現在の得点は#{@hands.calculate_score}点です。"
  end

  def is_bust?
    hands.calculate_score > NUMBER_OF_BLACKJACK
  end
end
