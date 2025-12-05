# frozen_string_literal: true

require_relative "test_helper"

class TestPerson < Minitest::Test
  def setup
    @person = Person.new("テストプレイヤー")
  end

  def test_person_initialization
    assert_equal "テストプレイヤー", @person.name
    assert_equal 10000, @person.chip
    assert_instance_of Hands, @person.hands
    assert_equal 1, @person.hands_array.length
  end

  def test_bet
    @person.bet(100)

    assert_equal 100, @person.hands.bets
    assert_equal 9900, @person.chip
  end

  def test_double_down_bet
    @person.bet(100)
    @person.double_down_bet

    assert_equal 200, @person.hands.bets
    assert_equal 9800, @person.chip
  end

  def test_can_double_down_with_two_cards_and_enough_chips
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.add_card(Card.new(6, "ハート"))
    @person.hands.bet(100)

    assert @person.can_double_down?
  end

  def test_cannot_double_down_with_insufficient_chips
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.add_card(Card.new(6, "ハート"))
    @person.bet(10000) # This also reduces chip to 0

    refute @person.can_double_down?
  end

  def test_cannot_double_down_with_more_than_two_cards
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.add_card(Card.new(6, "ハート"))
    @person.hands.add_card(Card.new(2, "ダイヤ"))
    @person.hands.bet(100)

    refute @person.can_double_down?
  end

  def test_can_surrender
    @person.hands.add_card(Card.new(10, "スペード"))
    @person.hands.add_card(Card.new(6, "ハート"))

    assert @person.can_surrender?
  end

  def test_cannot_surrender_with_more_than_two_cards
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.add_card(Card.new(6, "ハート"))
    @person.hands.add_card(Card.new(2, "ダイヤ"))

    refute @person.can_surrender?
  end

  def test_cannot_surrender_after_split
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.add_card(Card.new(5, "ハート"))
    @person.hands.bet(100)
    @person.split_hands

    refute @person.can_surrender?
  end

  def test_can_split
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.hands.bet(100)

    assert @person.can_split?
  end

  def test_cannot_split_without_pair
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(7, "ハート"))
    @person.hands.bet(100)

    refute @person.can_split?
  end

  def test_cannot_split_with_insufficient_chips
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(10000) # This also reduces chip to 0

    refute @person.can_split?
  end

  def test_initialize_person
    @person.hands.add_card(Card.new(5, "スペード"))
    @person.hands.bet(100)
    @person.initialize_person

    assert_empty @person.hands.hands
    assert_equal 0, @person.hands.bets
    assert_equal 1, @person.hands_array.length
  end

  def test_add_chip_surrender
    @person.hands.bet(100)
    @person.add_chip_surrender

    assert_equal 10050, @person.chip # 10000 + 50 (half of 100)
  end

  def test_add_chip_win
    @person.hands.bet(100)
    @person.add_chip_win

    assert_equal 10200, @person.chip # 10000 + 200
  end

  def test_add_chip_draw
    @person.hands.bet(100)
    @person.add_chip_draw

    assert_equal 10100, @person.chip # 10000 + 100
  end

  def test_add_chip
    @person.add_chip(500)
    assert_equal 10500, @person.chip
  end

  # Note: decide_action is now implemented in subclasses (Dealer, Player, CPU)
  # These tests have been moved to test_dealer.rb

  def test_receive_card
    card = Card.new(5, "スペード")
    @person.receive_card(card)

    assert_equal 1, @person.hands.length
    assert_includes @person.hands.hands, card
  end

  def test_receive_card_bust
    @person.hands.add_card(Card.new(10, "スペード"))
    @person.hands.add_card(Card.new(10, "ハート"))
    @person.receive_card(Card.new(5, "ダイヤ"))

    assert_equal "bust", @person.hands.state
  end

  def test_is_bust?
    @person.hands.add_card(Card.new(10, "スペード"))
    @person.hands.add_card(Card.new(10, "ハート"))
    @person.hands.add_card(Card.new(5, "ダイヤ"))

    assert @person.is_bust?
  end

  def test_is_not_bust
    @person.hands.add_card(Card.new(10, "スペード"))
    @person.hands.add_card(Card.new(10, "ハート"))

    refute @person.is_bust?
  end

  def test_split_hands
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(100) # This reduces chip to 9900
    @person.split_hands

    assert_equal 2, @person.hands_array.length
    assert_equal 1, @person.hands_array[0].length
    assert_equal 1, @person.hands_array[1].length
    assert_equal 100, @person.hands_array[0].bets
    assert_equal 100, @person.hands_array[1].bets
    assert_equal 9800, @person.chip # 9900 - 100 (additional bet for split)
  end

  def test_switching_hands
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(100)
    @person.split_hands

    first_hands = @person.hands
    @person.switching_hands

    refute_equal first_hands, @person.hands
    assert_equal @person.hands_array[1], @person.hands
  end

  def test_switching_hands_cycles
    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(100)
    @person.split_hands

    first_hands = @person.hands
    @person.switching_hands
    @person.switching_hands

    assert_equal first_hands, @person.hands
  end

  def test_get_hands_index
    assert_equal 0, @person.get_hands_index

    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(100)
    @person.split_hands
    @person.switching_hands

    assert_equal 1, @person.get_hands_index
  end

  def test_hands_number
    assert_equal 1, @person.hands_number

    @person.hands.add_card(Card.new(8, "スペード"))
    @person.hands.add_card(Card.new(8, "ハート"))
    @person.bet(100)
    @person.split_hands

    assert_equal 2, @person.hands_number
  end
end
