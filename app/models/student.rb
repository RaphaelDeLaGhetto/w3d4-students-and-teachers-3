class Student < ActiveRecord::Base
  has_and_belongs_to_many :teachers, before_add: :teacher_status
  # 2016-1-3 http://stackoverflow.com/questions/13784845/how-would-one-validate-the-format-of-an-email-field-in-activerecord
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_uniqueness_of :email
  validate :must_be_age_of_majority
  validate :teacher_status
  after_save :notify_teachers

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

    def notify_teachers
      teachers.each do |teacher|
        teacher.last_student_added_at = Date.today
        teacher.save
      end
    end

    def teacher_status(teacher=nil)
      if teacher && teacher.retirement_date
        errors.add(:teacher, "that teacher retired")
        raise "That teacher retired"
      end
    end
end
