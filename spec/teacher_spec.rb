require_relative 'spec_helper'

describe Teacher do
  before(:all) do
    raise RuntimeError, "be sure to run 'rake db:migrate' before running these specs" unless ActiveRecord::Base.connection.table_exists?(:students)
  end

#  context '#name and #age' do
#    before(:each) do
#      @student = Teacher.new
#      @student.assign_attributes(
#        first_name: 'Happy',
#        last_name: 'Gilmore',
#        gender: 'male',
#        birthday: Date.new(1970, 9, 1)
#      )
#    end
#
#    it 'should have name and age methods' do
#      [:name, :age].each { |method| expect(@student).to respond_to(method) }
#    end
#
#    it 'should concatenate first and last name' do
#      expect(@student.name).to eq('Happy Gilmore')
#    end
#
#    it 'should be the right age' do
#      now = Date.today
#      age = now.year - @student.birthday.year - ((now.month > @student.birthday.month || (now.month == @student.birthday.month && now.day >= @student.birthday.day)) ? 0 : 1)
#      expect(@student.age).to eq(age)
#    end
#  end
#
  context 'validations' do
#    before(:each) do
#      @student = Teacher.new
#      @student.assign_attributes(
#        first_name: 'Kreay',
#        last_name: 'Shawn',
#        birthday: Date.new(1989, 9, 24),
#        gender: 'female',
#        email: 'kreayshawn@oaklandhiphop.net',
#        phone: '(510) 555-1212 x4567'
#      )
#    end
#
    it 'flags a retirement date prior to hiring as invalid' do
      @teacher = Teacher.new(retirement_date: Date.today, hire_date: Date.tomorrow)
      expect(@teacher).to be_invalid
      expect(@teacher.errors[:retirement_date]).to include("can't retire before being hired")
    end

    it 'flags a retirement date with no hiring date as invalid' do
      @teacher = Teacher.new(retirement_date: Date.today)
      expect(@teacher).to be_invalid
      expect(@teacher.errors[:retirement_date]).to include("can't retire before being hired")
    end

    it 'correctly validates a retirement date subsequent to hiring' do
      @teacher = Teacher.new(retirement_date: Date.today, hire_date: Date.yesterday)
      expect(@teacher).to be_valid
    end

    it "isn't bothered by a nil hire/retirement date" do
      @teacher = Teacher.new
      expect(@teacher).to be_valid
    end

    it "clears teacher_ids for students of a retired teacher" do
      @teacher = Teacher.create!(hire_date: Date.yesterday)
      @student1 = Student.create!(email: 'student1@lhl.com', teacher: @teacher, birthday: Date.parse('1978-09-08'))
      @student2 = Student.create!(email: 'student2@lhl.com', teacher: @teacher, birthday: Date.parse('1980-04-07'))

      expect(@student1.teacher).to eq(@teacher)
      expect(@student2.teacher).to eq(@teacher)

      @teacher.retirement_date = Date.today
      @teacher.save

      @student1.reload
      @student2.reload

      expect(@student1.teacher).to be_nil
      expect(@student2.teacher).to be_nil
    end

#    it "shouldn't accept invalid emails" do
#      ['XYZ!bitnet', '@.', 'a@b.c'].each do |address|
#        @student.assign_attributes(email: address)
#        expect(@student).to_not be_valid
#      end
#    end
#
#    it 'should accept valid emails' do
#      ['joe@example.com', 'info@bbc.co.uk', 'bugs@facebook.com'].each do |address|
#        @student.assign_attributes(email: address)
#        expect(@student).to be_valid
#      end
#    end
#
#    it "shouldn't accept toddlers" do
#      @student.assign_attributes(birthday: Date.today - 3.years)
#      expect(@student).to_not be_valid
#    end
#
#    it "shouldn't allow two students with the same email" do
#      Teacher.create!(
#        birthday: @student.birthday,
#        email: @student.email,
#        phone: @student.phone
#      )
#      expect(@student).to_not be_valid
#    end
  end
  
#  context 'callbacks' do
#    before(:each) do
#      @teacher = Teacher.create
#
#      @student = Teacher.new(
#        first_name: 'Kreay',
#        last_name: 'Shawn',
#        birthday: Date.new(1989, 9, 24),
#        gender: 'female',
#        email: 'kreayshawn@oaklandhiphop.net',
#        phone: '(510) 555-1212 x4567'
#      )
#    end
#
#    it "updates last_student_added_at field in the new student's teacher record" do
#      expect(@teacher.last_student_added_at).to eq(nil)
#
#      @student.teacher = @teacher
#      @student.save
#
#      expect(@teacher.last_student_added_at).to eq(Date.today)
#    end
#  end
end
