class AddColumnDayOfWeeksToSpeechSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :speech_schedules, :wday, :text, :default => "---\n- 0\n- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n", :null => false
  end
end
