# frozen_string_literal: true

require_relative "./card.rb"

class Deck
  def initialize
    @deck = create_deck
  end

  def create_deck
    %w[スペード クラブ ハート ダイヤ].flat_map do |suit|
      (1..13).map { |rank| Card.new(rank, suit) }
    end
  end

  def shuffle_deck
    @deck.shuffle!
  end

  def deal_out
    @deck.pop
  end

  def to_s
    @deck.reduce("") { |str, card| str + card.to_s }
  end
end
