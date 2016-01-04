class Student < ActiveRecord::Base
  belongs_to :teacher
  # 2016-1-3 http://stackoverflow.com/questions/13784845/how-would-one-validate-the-format-of-an-email-field-in-activerecord
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_uniqueness_of :email
  validate :must_be_age_of_majority
  validate :teacher_status
  after_save :notify_teacher, if: :teacher

  def name
    "#{first_name} #{last_name}"
  end

  def age
    now = Date.today
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  private
    def must_be_age_of_majority
      errors.add(:birthday, "that student is too young") if age < 17
    end

    def notify_teacher
      teacher.last_student_added_at = Date.today
      teacher.save
    end

    def teacher_status
      errors.add(:teacher, "that teacher retired") if teacher && teacher.retirement_date
    end
end
