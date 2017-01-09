class AddColumnOnceOnlyToSpeechSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :speech_schedules, :once_only, :boolean, :default => false, :null => false
  end
end
