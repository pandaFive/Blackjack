# frozen_string_literal: true

require_relative "./card.rb"

class Deck
  def initialize
    @deck = create_deck
  end

  def create_deck
    %w[スペード クラブ ハート ダイヤ].reduce([]) do |deck, suit|
      suit_part = (1..13).reduce([]) do |part, rank|
        part.push(Card.new(rank, suit))
      end
      deck.concat(suit_part)
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
