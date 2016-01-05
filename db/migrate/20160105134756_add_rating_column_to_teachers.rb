class AddRatingColumnToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :rating, :decimal
  end
end
