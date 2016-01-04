class RemoveTeacherReferenceFromStudents < ActiveRecord::Migration
  def change
    remove_reference :students, :teacher
  end
end
