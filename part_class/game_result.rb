# frozen_string_literal: true

require_relative "./person.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"

class GameResult
  attr_reader :person, :is_win, :message

  def initialize(dealer, player)
    @person = player
    create_result(dealer, player)
  end

  private
    def set_result(result, message)
      @is_win = result
      @message = message
    end

    def create_result(dealer, player)
      if player.is_bust?
        set_result(false, "#{player.name}はbustしました。#{player.name}の負けです。")
      elsif dealer.is_bust?
        set_result(true, "#{dealer.name}はbustしました。#{player.name}の勝ちです！")
      else
        compare_scores(dealer, player)
      end
    end

    def compare_scores(dealer, player)
      dealer_score = calculate_score(dealer)
      player_score = calculate_score(player)

      if player_score > dealer_score
        set_result(true, "#{player.name}の得点は#{player_score}点でした。#{player.name}の勝ちです。#{player.bets * 2}ポイント獲得します。")
      elsif player_score < dealer_score
        set_result(false, "#{player.name}の得点は#{player_score}点でした。#{player.name}の負けです。")
      else
        set_result(nil, "#{player.name}と#{dealer.name}は同じ点数でした。引き分けです。")
      end
    end

    def calculate_score(person)
      person.hands.calculate_score
    end
end
