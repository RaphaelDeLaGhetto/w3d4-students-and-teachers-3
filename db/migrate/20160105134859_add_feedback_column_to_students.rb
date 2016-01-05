class AddFeedbackColumnToStudents < ActiveRecord::Migration
  def change
    add_column :students, :feedback, :integer
  end
end
