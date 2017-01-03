class CreateSpeechSchedules < ActiveRecord::Migration[5.0]
  def up
    create_table :speech_schedules do |attr|
      attr.string :name, :null => false
      attr.integer :frequency, :null => false, :default => 60
      attr.string :at, :null => false
      attr.text :speech_text, :null => false
      attr.timestamp
    end
  end

  def down
    drop_table :speech_schedules
  end
end
