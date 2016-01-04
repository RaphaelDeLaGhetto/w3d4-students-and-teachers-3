class Teacher < ActiveRecord::Base
  validates_uniqueness_of :email
  has_many :students
  validate :retirement_date_is_after_hire_date
  after_save :check_retirement_status

  private
    def retirement_date_is_after_hire_date
      errors.add(:retirement_date, "can't retire before being hired") if retirement_date && (hire_date.nil? || retirement_date < hire_date)
    end

    def check_retirement_status
      students.each { |student| student.teacher = nil; student.save } if retirement_date
    end
end
