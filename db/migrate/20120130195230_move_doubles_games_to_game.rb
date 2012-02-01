class MoveDoublesGamesToGame < ActiveRecord::Migration

  class Game < ActiveRecord::Base
  end
  class DoublesGame < ActiveRecord::Base
  end
  class GameOutcome < ActiveRecord::Base
  end

  def up
    DoublesGame.reset_column_information
    DoublesGame.all.each do |dbls_game|

      Game.reset_column_information
      game = Game.create( :created_at => dbls_game.created_at, :updated_at => dbls_game.updated_at, :loser_score => dbls_game.loser_score )

      GameOutcome.reset_column_information
      GameOutcome.create( :game_id => game.id, :player_id => dbls_game.winner1_id, :win => 1 )
      GameOutcome.create( :game_id => game.id, :player_id => dbls_game.winner2_id, :win => 1 )

      GameOutcome.reset_column_information
      GameOutcome.create( :game_id => game.id, :player_id => dbls_game.loser1_id, :win => 0 )
      GameOutcome.create( :game_id => game.id, :player_id => dbls_game.loser2_id, :win => 0 )
      dbls_game.delete
    end
  end

  def down
    GameOutcome.where(:id => GameOutcome.select("id").group("game_id").having("count(*) > ?", 3)).each do | dbls_game_outcome |
      game_winners = GameOutcome.where( :game_id => dbls_game_outcome.game_id, :win => true )
      game_losers  = GameOutcome.where( :game_id => dbls_game_outcome.game_id, :win => false )
      game = Game.where( :id => dbls_game_outcome.game_id ).first

      DoublesGame.reset_column_information
      DoublesGame.create( :winner1_id => game_winners.first.player_id, :winner2_id => game_winners.last.player_id, :loser1_id => game_losers.first.player_id, :loser2_id => game_losers.last.player_id, :loser_score => game.loser_score )

      Game.delete(game)
      GameOutcome.delete(game_winners)
      GameOutcome.delete(game_losers)
    end
  end
end
