class AddStudentTeacherRelationship < ActiveRecord::Migration
  def change
    add_reference :students, :teacher, index: true
  end
end
