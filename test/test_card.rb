# frozen_string_literal: true

require_relative "test_helper"

class TestCard < Minitest::Test
  def test_card_initialization
    card = Card.new(1, "スペード")
    assert_equal 1, card.rank
    assert_equal "スペード", card.suit
    assert_equal "A", card.number
  end

  def test_card_number_mapping_ace
    card = Card.new(1, "ハート")
    assert_equal "A", card.number
  end

  def test_card_number_mapping_numbers
    (2..10).each do |rank|
      card = Card.new(rank, "クラブ")
      assert_equal rank.to_s, card.number
    end
  end

  def test_card_number_mapping_face_cards
    card_j = Card.new(11, "ダイヤ")
    card_q = Card.new(12, "スペード")
    card_k = Card.new(13, "ハート")

    assert_equal "J", card_j.number
    assert_equal "Q", card_q.number
    assert_equal "K", card_k.number
  end

  def test_to_s
    card = Card.new(1, "スペード")
    assert_equal "スペードのA", card.to_s

    card2 = Card.new(10, "ハート")
    assert_equal "ハートの10", card2.to_s
  end
end
