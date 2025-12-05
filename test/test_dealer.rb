# frozen_string_literal: true

require_relative "test_helper"

class TestDealer < Minitest::Test
  def setup
    @dealer = Dealer.new
  end

  def test_dealer_initialization
    assert_equal "ディーラー", @dealer.name
    assert_equal 10000, @dealer.chip
  end

  def test_initial_receive_first_card
    card = Card.new(5, "スペード")
    @dealer.initial_receive(card)

    assert_equal 1, @dealer.hands.length
    assert_includes @dealer.hands.hands, card
  end

  def test_initial_receive_second_card
    @dealer.initial_receive(Card.new(5, "スペード"))
    @dealer.initial_receive(Card.new(10, "ハート"))

    assert_equal 2, @dealer.hands.length
  end

  def test_get_up_card_score_number_card
    @dealer.hands.add_card(Card.new(7, "スペード"))
    assert_equal 7, @dealer.get_up_card_score
  end

  def test_get_up_card_score_face_card
    @dealer.hands.add_card(Card.new(11, "スペード")) # J
    assert_equal 10, @dealer.get_up_card_score
  end

  def test_get_up_card_score_ten
    @dealer.hands.add_card(Card.new(10, "スペード"))
    assert_equal 10, @dealer.get_up_card_score
  end

  def test_get_up_card_score_ace
    @dealer.hands.add_card(Card.new(1, "スペード")) # A
    assert_equal 11, @dealer.get_up_card_score
  end

  def test_get_up_card_score_with_second_card
    @dealer.hands.add_card(Card.new(7, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))

    # Should still return the first card's score
    assert_equal 7, @dealer.get_up_card_score
  end

  def test_get_up_card_score_king
    @dealer.hands.add_card(Card.new(13, "スペード")) # K
    assert_equal 10, @dealer.get_up_card_score
  end

  def test_get_up_card_score_queen
    @dealer.hands.add_card(Card.new(12, "スペード")) # Q
    assert_equal 10, @dealer.get_up_card_score
  end

  def test_show_second_card
    @dealer.hands.add_card(Card.new(7, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))

    # Just ensure it doesn't raise an error
    @dealer.show_second_card
    assert_equal 2, @dealer.hands.length
  end

  def test_decide_action_hit_when_below_17
    @dealer.hands.add_card(Card.new(5, "スペード"))
    @dealer.hands.add_card(Card.new(10, "ハート"))

    assert_equal "Hit", @dealer.decide_action
  end

  def test_decide_action_stand_when_17_or_above
    @dealer.hands.add_card(Card.new(10, "スペード"))
    @dealer.hands.add_card(Card.new(7, "ハート"))

    assert_equal "Stand", @dealer.decide_action
  end
end
