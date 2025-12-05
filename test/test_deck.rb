# frozen_string_literal: true

require_relative "test_helper"

class TestDeck < Minitest::Test
  def test_deck_initialization
    deck = Deck.new
    assert_instance_of Deck, deck
  end

  def test_deck_has_52_cards
    deck = Deck.new
    cards_dealt = []
    52.times { cards_dealt << deck.deal_out }

    assert_equal 52, cards_dealt.length
    assert_nil deck.deal_out # Should be empty after 52 cards
  end

  def test_deck_contains_all_suits
    deck = Deck.new
    cards = []
    52.times { cards << deck.deal_out }

    suits = cards.map(&:suit).uniq.sort
    assert_equal ["クラブ", "スペード", "ダイヤ", "ハート"], suits
  end

  def test_deck_contains_all_ranks
    deck = Deck.new
    cards = []
    52.times { cards << deck.deal_out }

    ranks = cards.map(&:rank).uniq.sort
    assert_equal (1..13).to_a, ranks
  end

  def test_deck_has_13_cards_per_suit
    deck = Deck.new
    cards = []
    52.times { cards << deck.deal_out }

    %w[スペード クラブ ハート ダイヤ].each do |suit|
      suit_cards = cards.select { |card| card.suit == suit }
      assert_equal 13, suit_cards.length
    end
  end

  def test_shuffle_deck_changes_order
    deck1 = Deck.new
    deck2 = Deck.new

    deck1.shuffle_deck
    deck2.shuffle_deck

    cards1 = []
    cards2 = []

    52.times do
      cards1 << deck1.deal_out
      cards2 << deck2.deal_out
    end

    # It's extremely unlikely that two shuffled decks are in the same order
    same_order = cards1.each_with_index.all? do |card, i|
      card.rank == cards2[i].rank && card.suit == cards2[i].suit
    end

    refute same_order, "Two shuffled decks should not be in the same order"
  end

  def test_deal_out_removes_card
    deck = Deck.new
    first_card = deck.deal_out

    assert_instance_of Card, first_card

    remaining_cards = []
    51.times { remaining_cards << deck.deal_out }

    assert_equal 51, remaining_cards.length
  end
end
