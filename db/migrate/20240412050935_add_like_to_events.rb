# frozen_string_literal: true

class AddLikeToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :like, :integer, default: 0
  end
end
