# frozen_string_literal: true

class Card
  attr_reader :number, :suit, :rank

  @@NUMBER_TABLE = {
    1 => "A",
    2 => "2",
    3 => "3",
    4 => "4",
    5 => "5",
    6 => "6",
    7 => "7",
    8 => "8",
    9 => "9",
    10 => "10",
    11 => "J",
    12 => "Q",
    13 => "K"
  }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @number = @@NUMBER_TABLE[rank]
  end

  def to_s
    "[#{@rank} #{@number} #{@suit}]"
  end
end
