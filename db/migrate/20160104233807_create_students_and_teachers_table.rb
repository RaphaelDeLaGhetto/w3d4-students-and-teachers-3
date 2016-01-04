class CreateStudentsAndTeachersTable < ActiveRecord::Migration
  def change
    create_table :students_teachers do |t|
      t.belongs_to :students, index: true
      t.belongs_to :teachers, index: true
    end
  end
end
