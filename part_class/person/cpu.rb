# frozen_string_literal: true

require_relative "../../config/application.rb"
require_relative "../person.rb"

class CPU < Person
  def initialize(name_number)
    super("CPU#{name_number}")
  end

  def decide_action(up_card_score)
    score_call
    if hands.has_A?
      soft_hand_decide(up_card_score)
    else
      hard_hand_decide(up_card_score)
    end
  end

  private
    def hard_hand_decide(up_card_score)
      score = hands.calculate_score
      if score <= 11
        "Hit"
      elsif score >= 17
        "Stand"
      elsif up_card_score > 7
        "Hit"
      else
        "Stand"
      end
    end

    # 手札にあるAを11として扱う場合のアクション
    def soft_hand_decide(up_card_score)
      score = hands.calculate_score

      if score <= 17
        "Hit"
      elsif score >= 19
        "Stand"
      elsif up_card_score >= 9
        "Hit"
      else
        "Stand"
      end
    end
end
