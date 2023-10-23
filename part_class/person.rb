# frozen_string_literal: true

require_relative "../config/application.rb"
require_relative "./hands.rb"

class Person
  attr_reader :name, :state, :hands
  def initialize(name)
    @name = name
    @state = "init"
    @hands = Hands.new
  end

  def decide_action
    if @hands.calculate_score < 17
      "Hit"
    else
      "Stand"
    end
  end

  def receive_card(card)
    @hands.add_card(card)

    puts "#{name}の引いたカードは#{card}です。"

    score = @hands.calculate_score

    if score > 21
      @state = "bust"

      puts "#{@name}はbustしました。"
    end

    sleep SLEEP_SECOND
  end

  def to_s
    "#{@name}: #{@state}"
  end

  def is_bust?
    hands.calculate_score > 21
  end
end
