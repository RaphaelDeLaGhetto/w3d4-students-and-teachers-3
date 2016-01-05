require_relative 'spec_helper'

describe Teacher do
  before(:all) do
    raise RuntimeError, "be sure to run 'rake db:migrate' before running these specs" unless ActiveRecord::Base.connection.table_exists?(:teachers)
  end

  context 'validations' do
    it 'flags a retirement date prior to hiring as invalid' do
      teacher = Teacher.new(retirement_date: Date.today, hire_date: Date.tomorrow)
      expect(teacher).to be_invalid
      expect(teacher.errors[:retirement_date]).to include("can't retire before being hired")
    end

    it 'flags a retirement date with no hiring date as invalid' do
      teacher = Teacher.new(retirement_date: Date.today)
      expect(teacher).to be_invalid
      expect(teacher.errors[:retirement_date]).to include("can't retire before being hired")
    end

    it 'correctly validates a retirement date subsequent to hiring' do
      teacher = Teacher.new(retirement_date: Date.today, hire_date: Date.yesterday)
      expect(teacher).to be_valid
    end

    it "isn't bothered by a nil hire/retirement date" do
      teacher = Teacher.new
      expect(teacher).to be_valid
    end

    it "clears teacher_ids for students of a retired teacher" do
      teacher = Teacher.create!(hire_date: Date.yesterday)
      student1 = Student.create!(email: 'student1@lhl.com', birthday: Date.parse('1978-09-08'))
      student1.teachers << teacher
      student2 = Student.create!(email: 'student2@lhl.com', birthday: Date.parse('1980-04-07'))
      student2.teachers << teacher

      expect(student1.teachers.last).to eq(teacher)
      expect(student2.teachers.last).to eq(teacher)

      teacher.retirement_date = Date.today
      teacher.save

      student1.reload
      student2.reload

      expect(student1.teachers.last).to be_nil
      expect(student2.teachers.last).to be_nil
    end
  end
end
