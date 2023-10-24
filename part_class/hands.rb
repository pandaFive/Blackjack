# frozen_string_literal: true

require_relative "./card.rb"

class Hands
  attr_reader :hands
  def initialize
    @hands = []
  end

  def add_card(card)
    return unless card.is_a?(Card)

    @hands.push(card)
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

  def empty?
    @hands.empty?
  end

  def has_A?
    hands.any? { |card| card.rank == 1 }
  end

  def to_s
    @hands.reduce("") do |result, card|
      result + "#{card.suit}の#{card.number} "
    end
  end
end
