# frozen_string_literal: true

require_relative "./person.rb"
require_relative "./person/dealer.rb"
require_relative "./person/player.rb"

# インスタンス変数 person, is_win, message, state
class GameResult
  attr_reader :person, :is_win, :message, :state

  def initialize(dealer, player)
    @person = player
    @dealer = dealer
    @destination = build_destination
    create_result
  end

  private
    def set_result(result, message, state)
      @is_win = result
      @message = message
      @state = state
    end

    def build_destination
      if @person.hands_number == 1
        @person.name
      else
        "#{@person.name}の#{@person.get_hands_index + 1}つ目の手札"
      end
    end

    def create_result
      if @person.hands.state == "Surrender"
        handle_surrender
      elsif @person.is_bust?
        handle_player_bust
      elsif @dealer.is_bust?
        handle_dealer_bust
      else
        compare_scores
      end
    end

    def handle_surrender
      message = "#{@destination}はSurrenderしている。betしたポイントの半分が戻ってきます。"
      set_result(nil, message, @person.hands.state)
    end

    def handle_player_bust
      message = "#{@destination}はbustしました。#{@destination}の負けです。"
      set_result(false, message, @person.hands.state)
    end

    def handle_dealer_bust
      payout = @person.hands.bets * 2
      message = "#{@dealer.name}はbustしました。#{@destination}の勝ちです！#{payout}ポイント獲得します。"
      set_result(true, message, @person.hands.state)
    end

    def compare_scores
      dealer_score = @dealer.hands.calculate_score
      player_score = @person.hands.calculate_score

      if player_score > dealer_score
        handle_player_win(player_score)
      elsif player_score < dealer_score
        handle_player_loss(player_score)
      else
        handle_draw
      end
    end

    def handle_player_win(score)
      payout = @person.hands.bets * 2
      message = "#{@destination}の得点は#{score}点でした。#{@destination}の勝ちです。#{payout}ポイント獲得します。"
      set_result(true, message, @person.hands.state)
    end

    def handle_player_loss(score)
      message = "#{@destination}の得点は#{score}点でした。#{@destination}の負けです。"
      set_result(false, message, @person.hands.state)
    end

    def handle_draw
      message = "#{@destination}と#{@dealer.name}は同じ点数でした。引き分けです。"
      set_result(nil, message, @person.hands.state)
    end
end
