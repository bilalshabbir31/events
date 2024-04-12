# frozen_string_literal: true

class AddScheduledAtToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :scheduled_at, :datetime
  end
end
