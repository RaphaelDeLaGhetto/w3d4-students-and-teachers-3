require_relative 'spec_helper'

describe Student do
  before(:all) do
    raise RuntimeError, "be sure to run 'rake db:migrate' before running these specs" unless ActiveRecord::Base.connection.table_exists?(:students)
  end

  context '#name and #age' do
    before(:each) do
      @student = Student.new
      @student.assign_attributes(
        first_name: 'Happy',
        last_name: 'Gilmore',
        gender: 'male',
        birthday: Date.new(1970, 9, 1)
      )
    end

    it 'should have name and age methods' do
      [:name, :age].each { |method| expect(@student).to respond_to(method) }
    end

    it 'should concatenate first and last name' do
      expect(@student.name).to eq('Happy Gilmore')
    end

    it 'should be the right age' do
      now = Date.today
      age = now.year - @student.birthday.year - ((now.month > @student.birthday.month || (now.month == @student.birthday.month && now.day >= @student.birthday.day)) ? 0 : 1)
      expect(@student.age).to eq(age)
    end
  end

  context 'validations' do
    before(:each) do
      @student = Student.new
      @student.assign_attributes(
        first_name: 'Kreay',
        last_name: 'Shawn',
        birthday: Date.new(1989, 9, 24),
        gender: 'female',
        email: 'kreayshawn@oaklandhiphop.net',
        phone: '(510) 555-1212 x4567'
      )
    end

    it 'should accept valid info' do
      expect(@student).to be_valid
    end

    it "shouldn't accept invalid emails" do
      ['XYZ!bitnet', '@.', 'a@b.c'].each do |address|
        @student.assign_attributes(email: address)
        expect(@student).to_not be_valid
      end
    end

    it 'should accept valid emails' do
      ['joe@example.com', 'info@bbc.co.uk', 'bugs@facebook.com'].each do |address|
        @student.assign_attributes(email: address)
        expect(@student).to be_valid
      end
    end

    it "shouldn't accept toddlers" do
      @student.assign_attributes(birthday: Date.today - 3.years)
      expect(@student).to_not be_valid
    end

    it "shouldn't allow two students with the same email" do
      Student.create!(
        birthday: @student.birthday,
        email: @student.email,
        phone: @student.phone
      )
      expect(@student).to_not be_valid
    end

    it "shouldn't allow two students with the same email" do
      Student.create!(
        birthday: @student.birthday,
        email: @student.email,
        phone: @student.phone
      )
      expect(@student).to_not be_valid
    end

    it "won't register a student to a retired teacher" do
      @student.save
      teacher = Teacher.create!(hire_date: Date.yesterday, retirement_date: Date.today)
      expect(@student.teachers.count).to eq(0)
      expect{ @student.teachers << teacher }.to raise_error('That teacher retired')
      expect(@student.teachers.count).to eq(0)
    end
  end
  
  context 'callbacks' do
    before(:each) do
      @student = Student.create!(
        first_name: 'Kreay',
        last_name: 'Shawn',
        birthday: Date.new(1989, 9, 24),
        gender: 'female',
        email: 'kreayshawn@oaklandhiphop.net',
        phone: '(510) 555-1212 x4567'
      )
      @teacher = Teacher.create!(email: 'daniel@capitolhill.ca')
    end

    it "updates last_student_added_at field in the new student's teacher record" do
      expect(@teacher.last_student_added_at).to eq(nil)

      @student.teachers << @teacher
      @student.save

      expect(@teacher.last_student_added_at).to eq(Date.today)
    end

    it "sets the teacher rating if that teacher's rating is nil" do
      expect(@teacher.rating).to eq(nil)

      @student.teachers << @teacher
      @student.feedback = 3
      @student.save

      expect(@teacher.rating).to eq(3)
    end

    it "recalculates teacher ratings when the feedback column is set" do
      @teacher.rating = 3
      @teacher.save

      @student.teachers << @teacher
      @student.feedback = 4
      @student.save

      expect(@teacher.rating).to eq(3.5)
    end

    it "updates all teacher ratings when the feedback column is set" do
      @teacher.rating = 3
      @teacher.save

      teacher1 = Teacher.create!(email: 'teacher1@example.edu', rating: 1)
      teacher2 = Teacher.create!(email: 'teacher2@example.edu', rating: 4)
      teacher3 = Teacher.create!(email: 'teacher3@example.edu')

      @student.teachers << @teacher << teacher1 << teacher2 << teacher3 
      @student.feedback = 4
      @student.save

      expect(@teacher.rating).to eq(3.5)
      expect(teacher1.rating).to eq(2.5)
      expect(teacher2.rating).to eq(4)
      expect(teacher3.rating).to eq(4)
    end
  end
end
