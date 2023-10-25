# frozen_string_literal: true

require_relative "../../../config/application.rb"
require_relative "../person.rb"

class CPU < Person
  def initialize(name_number)
    super("CPU#{name_number}")
  end

  def bet
    sleep SLEEP_SECOND
    lower_limit = (chip / 100).floor.to_i
    upper_limit = (chip / 10).floor.to_i
    @bets = rand(lower_limit..upper_limit)
    @chip -= @bets
    puts "#{name}は#{@bets}ポイントベットした。"
  end

  def decide_action(up_card_score)
    score_call
    sleep SLEEP_SECOND
    if hands.has_A?
      soft_hand_decide(up_card_score)
    else
      hard_hand_decide(up_card_score)
    end
  end

  private
    def hard_hand_decide(up_card_score)
      score = hands.calculate_score
      decide = if score <= 8
        "Hit"
      elsif score <= 11
        if can_double_down?
          if score == 9 && up_card_score >= 3 && up_card_score <= 6
            "Double Down"
          elsif score == 10 && up_card_score <= 9
            "Double Down"
          elsif score == 11 && up_card_score <= 10
            "Double Down"
          else
            "Hit"
          end
        else
          "Hit"
        end
      elsif score >= 17
        "Stand"
      elsif @action_count == 0 && up_card_score >= 9 && score == 16
        "Surrender"
      elsif up_card_score >= 7
        "Hit"
      else
        "Stand"
      end
      @state = decide

      decide
    end

    # 手札にあるAを11として扱う場合のアクション
    def soft_hand_decide(up_card_score)
      score = hands.calculate_score

      decide = if can_double_down? && score <= 18
        if up_card_score == 5 && up_card_score == 6
          "Double Down"
        elsif up_card_score == 4 && score >= 15
          "Double Down"
        elsif up_card_score == 3 && score >= 17
          "Double Down"
        end
      elsif score <= 17
        "Hit"
      elsif score >= 19
        "Stand"
      elsif up_card_score >= 9
        "Hit"
      else
        "Stand"
      end

      @state = decide

      decide
    end
end
