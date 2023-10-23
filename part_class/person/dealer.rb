# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "../person.rb"

class Dealer < Person
  def initialize
    super("ディーラー")
  end

  def initial_receive(card)
    if @hands.empty?
      puts "ディーラーの引いたカードは#{card}です。"
    else
      puts "ディーラーの引いた2枚目のカードはわかりません。"
    end

    @hands.add_card(card)
    sleep SLEEP_SECOND
  end

  def show_second_card
    puts "ディーラーの引いた2枚目のカードは#{@hands.hands[1]}でした。"
  end

  def put_score
    puts "ディーラーの現在の得点は#{@hands.calculate_score}です。"
  end
end
