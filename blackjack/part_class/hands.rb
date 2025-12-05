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
    ace_count = count_aces
    base_score = calculate_base_score

    optimize_ace_value(base_score, ace_count)
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

  private

  def count_aces
    @hands.count { |card| card.rank == 1 }
  end

  def calculate_base_score
    @hands.reduce(0) do |score, card|
      score + (card.rank == 1 ? 0 : [card.rank, 10].min)
    end
  end

  def optimize_ace_value(base_score, ace_count)
    return base_score if ace_count.zero?

    # 1つのAceを11として扱えるか判定
    score_with_ace_as_11 = base_score + 11 + (ace_count - 1)

    if score_with_ace_as_11 <= 21
      score_with_ace_as_11
    else
      base_score + ace_count
    end
  end
end
