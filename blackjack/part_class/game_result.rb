# frozen_string_literal: true

require_relative "./person.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"

# インスタンス変数 person, is_win, message, state
class GameResult
  attr_reader :person, :is_win, :message, :state

  def initialize(dealer, player)
    @person = player
    create_result(dealer, player)
  end

  private
    def set_result(result, message, state)
      @is_win = result
      @message = message
      @state = state
    end

    def create_destination
      if @person.hands_number == 1
        @person.name
      else
        "#{@person.name}の#{@person.get_hands_index + 1}つ目の手札"
      end
    end

    def create_result(dealer, player)
      destination = create_destination
      if player.hands.state == "Surrender"
        set_result(nil, "#{destination}はSurrenderしている。betしたポイントの半分が戻ってきます。", @person.hands.state)
      elsif player.is_bust?
        set_result(false, "#{destination}はbustしました。#{destination}の負けです。", @person.hands.state)
      elsif dealer.is_bust?
        set_result(true, "#{dealer.name}はbustしました。#{destination}の勝ちです！#{player.hands.bets * 2}ポイント獲得します。", @person.hands.state)
      else
        compare_scores(dealer, player)
      end
    end

    def compare_scores(dealer, player)
      dealer_score = calculate_score(dealer)
      player_score = calculate_score(player)
      destination = create_destination

      if player_score > dealer_score
        set_result(true, "#{destination}の得点は#{player_score}点でした。#{destination}の勝ちです。#{player.hands.bets * 2}ポイント獲得します。", @person.hands.state)
      elsif player_score < dealer_score
        set_result(false, "#{destination}の得点は#{player_score}点でした。#{destination}の負けです。", @person.hands.state)
      else
        set_result(nil, "#{destination}と#{dealer.name}は同じ点数でした。引き分けです。", @person.hands.state)
      end
    end

    def calculate_score(person)
      person.hands.calculate_score
    end
end
