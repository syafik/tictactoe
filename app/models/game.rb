class Game < ApplicationRecord
  enum status: { waiting_other_player: 0, ready: 1, running: 2, ended: 3 }

  belongs_to :user
  belongs_to :turn_player, class_name: 'Player', optional: true
  belongs_to :winner_player, class_name: 'Player', optional: true
  has_many :players

  accepts_nested_attributes_for :players

  validates :rowcols, presence: true
  # validates_uniqueness_of :code
  validates_numericality_of :rowcols, greater_than_or_equal_to: 3,
                                      less_than_or_equal_to: 10,
                                      message: 'must be a whole number between 3 and 10'

  # before_validation :generate_unique_code
  after_commit :create_default_board, on: :create

  def valid_for_join?(user)
    errors.add(:status, 'should have waiting other player status to join') unless waiting_other_player?
    errors.add(:status, 'could not join your own game.') if user_id == user.id
    errors.empty?
  end

  def your_turn?(current_player)
    errors.add(:status, 'This is not your turn') unless turn_player_id == current_player.id
    errors.empty?
  end

  def valid_move?(row:, col:)
    return true if board.blank?

    errors.add(:status, 'Invalid move') if board[row.to_i][col.to_i].positive?
    errors.add(:status, 'Invalid move, game is not running') unless running?
    errors.empty?
  end

  def create_default_board
    with_lock do
      self.board = []
      0.upto(rowcols - 1) do |row|
        0.upto(rowcols - 1) do |col|
          board[row] ||= []
          board[row][col] = 0
        end
      end
      save
    end
  end

  def reset
    create_default_board
    with_lock do
      update(turn_player_id: players.first.id, winner_player_id: nil)
    end
  end

  def update_board_and_change_turn(player, row, col)
    with_lock do
      updated_board = board
      updated_board[row.to_i][col.to_i] = player.sign.ord
      update(board: updated_board, turn_player_id: next_player_turn(player)&.id)

      winner = check_winner
      if winner.present?
        self.winner_player_id = players.where(sign: winner.chr).first.id
        ended!
      end
    end
  end

  def next_player_turn(player)
    players.where.not(id: player.id).first
  end

  def check_winner
    size = board.size

    # Check rows and columns
    (0...size).each do |i|
      return board[i][0] if board[i].uniq.length == 1 && board[i][0].positive?
      return board[0][i] if board.transpose[i].uniq.length == 1 && board[0][i].positive?
    end

    # Check diagonals
    return board[0][0] if board[0][0] == board[1][1] && board[1][1] == board[size - 1][size - 1] && board[0][0].positive?
    return board[0][size - 1] if board[0][size - 1] == board[1][1] && board[1][1] == board[size - 1][0] && board[0][size - 1].positive?

    nil # No winner
  end

  private

  def generate_unique_code
    self.code = SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
  end
end
