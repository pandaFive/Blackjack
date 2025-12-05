# frozen_string_literal: true

require_relative "test_helper"

class TestHands < Minitest::Test
  def test_hands_initialization
    hands = Hands.new
    assert_empty hands.hands
    assert_equal 0, hands.bets
    assert_equal "", hands.state
  end

  def test_add_card
    hands = Hands.new
    card = Card.new(5, "スペード")
    hands.add_card(card)

    assert_equal 1, hands.length
    assert_includes hands.hands, card
  end

  def test_add_card_rejects_non_card
    hands = Hands.new
    hands.add_card("not a card")

    assert_equal 0, hands.length
  end

  def test_bet
    hands = Hands.new
    hands.bet(100)

    assert_equal 100, hands.bets
  end

  def test_double_down_bet
    hands = Hands.new
    hands.bet(100)
    hands.double_down_bet

    assert_equal 200, hands.bets
  end

  def test_empty?
    hands = Hands.new
    assert hands.empty?

    hands.add_card(Card.new(5, "スペード"))
    refute hands.empty?
  end

  def test_length
    hands = Hands.new
    assert_equal 0, hands.length

    hands.add_card(Card.new(5, "スペード"))
    assert_equal 1, hands.length

    hands.add_card(Card.new(10, "ハート"))
    assert_equal 2, hands.length
  end

  def test_pop_card
    hands = Hands.new
    card1 = Card.new(5, "スペード")
    card2 = Card.new(10, "ハート")
    hands.add_card(card1)
    hands.add_card(card2)

    popped = hands.pop_card
    assert_equal card2, popped
    assert_equal 1, hands.length
  end

  def test_has_A?
    hands = Hands.new
    refute hands.has_A?

    hands.add_card(Card.new(5, "スペード"))
    refute hands.has_A?

    hands.add_card(Card.new(1, "ハート"))
    assert hands.has_A?
  end

  def test_clear_hand
    hands = Hands.new
    hands.add_card(Card.new(5, "スペード"))
    hands.add_card(Card.new(10, "ハート"))
    hands.clear_hand

    assert_empty hands.hands
  end

  # Score calculation tests
  def test_calculate_score_simple_cards
    hands = Hands.new
    hands.add_card(Card.new(5, "スペード"))
    hands.add_card(Card.new(7, "ハート"))

    assert_equal 12, hands.calculate_score
  end

  def test_calculate_score_face_cards
    hands = Hands.new
    hands.add_card(Card.new(11, "スペード")) # J
    hands.add_card(Card.new(12, "ハート"))  # Q

    assert_equal 20, hands.calculate_score
  end

  def test_calculate_score_face_card_with_number
    hands = Hands.new
    hands.add_card(Card.new(13, "スペード")) # K = 10
    hands.add_card(Card.new(5, "ハート"))

    assert_equal 15, hands.calculate_score
  end

  def test_calculate_score_ace_as_11
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(9, "ハート"))

    assert_equal 20, hands.calculate_score # A=11, 9 = 20
  end

  def test_calculate_score_ace_as_1
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(10, "ハート"))
    hands.add_card(Card.new(10, "ダイヤ"))

    assert_equal 21, hands.calculate_score # A=1, 10, 10 = 21
  end

  def test_calculate_score_multiple_aces_soft
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(1, "ハート"))   # A

    assert_equal 12, hands.calculate_score # A=11, A=1 = 12
  end

  def test_calculate_score_multiple_aces_hard
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(1, "ハート"))   # A
    hands.add_card(Card.new(9, "ダイヤ"))

    assert_equal 21, hands.calculate_score # A=1, A=1, 9 = 11
  end

  def test_calculate_score_three_aces
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(1, "ハート"))   # A
    hands.add_card(Card.new(1, "ダイヤ"))   # A

    assert_equal 13, hands.calculate_score # A=11, A=1, A=1 = 13
  end

  def test_calculate_score_blackjack
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード")) # A
    hands.add_card(Card.new(11, "ハート"))  # J

    assert_equal 21, hands.calculate_score # Blackjack!
  end

  def test_calculate_score_bust
    hands = Hands.new
    hands.add_card(Card.new(10, "スペード"))
    hands.add_card(Card.new(10, "ハート"))
    hands.add_card(Card.new(5, "ダイヤ"))

    assert_equal 25, hands.calculate_score
  end

  # Split tests
  def test_can_split_with_pair
    hands = Hands.new
    hands.add_card(Card.new(5, "スペード"))
    hands.add_card(Card.new(5, "ハート"))

    assert hands.can_split?
  end

  def test_can_split_with_face_cards
    hands = Hands.new
    hands.add_card(Card.new(11, "スペード")) # J
    hands.add_card(Card.new(12, "ハート"))   # Q

    assert hands.can_split? # Both are worth 10
  end

  def test_cannot_split_different_cards
    hands = Hands.new
    hands.add_card(Card.new(5, "スペード"))
    hands.add_card(Card.new(6, "ハート"))

    refute hands.can_split?
  end

  def test_cannot_split_with_more_than_two_cards
    hands = Hands.new
    hands.add_card(Card.new(5, "スペード"))
    hands.add_card(Card.new(5, "ハート"))
    hands.add_card(Card.new(5, "ダイヤ"))

    refute hands.can_split?
  end

  def test_to_s
    hands = Hands.new
    hands.add_card(Card.new(1, "スペード"))
    hands.add_card(Card.new(10, "ハート"))

    result = hands.to_s
    assert_includes result, "スペードのA"
    assert_includes result, "ハートの10"
  end
end
