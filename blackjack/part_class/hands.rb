# frozen_string_literal: true

require_relative "./card.rb"

class Hands
  attr_reader :hands, :bets, :state
  attr_writer :state
  def initialize
    @hands = []
    @bets = 0
    @state = ""
  end

  def add_card(card)
    return unless card.is_a?(Card)

    @hands.push(card)
  end

  def bet(bet_amount)
    @bets = bet_amount
  end

  def calculate_score
    count_one = 0

    score = @hands.reduce(0) do |result, card|
      if card.rank == 1
        count_one += 1
        result
      else
        result + [card.rank, 10].min
      end
    end

    unless count_one.zero?
      if 21 - score >= 10 + count_one
        score + 10 + count_one
      else
        score + count_one
      end
    else
      score
    end
  end

  def can_split?
    @hands.length == 2 && [@hands[0].rank, 10].min == [@hands[1].rank, 10].min
  end

  def clear_hand
    @hands = []
  end

  def double_down_bet
    @bets *= 2
  end

  def empty?
    @hands.empty?
  end

  def length
    @hands.length
  end

  def pop_card
    @hands.pop
  end

  def has_A?
    @hands.any? { |card| card.rank == 1 }
  end

  def to_s
    @hands.reduce("") do |result, card|
      result + "#{card.suit}の#{card.number} "
    end
  end
end
