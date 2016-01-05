class CreateStudentsAndTeachersTable < ActiveRecord::Migration
  def change
    create_table :students_teachers, id: false do |t|
      t.belongs_to :student, index: true
      t.belongs_to :teacher, index: true
    end
  end
end
