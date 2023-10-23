# frozen_string_literal: true

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

    score = @hands.calculate_score

    if score > 21
      @state = "bust"

      puts "#{@name} was busted"
    end
  end

  def to_s
    "#{@name}: #{@state}"
  end
end
