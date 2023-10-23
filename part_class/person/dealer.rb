# frozen_string_literal: true

require_relative "../person.rb"

class Dealer < Person
  def initialize
    super("ディーラー")
  end

  def show_up_card
    return if hands.empty?
    puts "ディーラーの引いたカードは#{@hands.hands[0]}です。"
    puts "ディーラーの引いた2枚目のカードはわかりません。"
  end
end
