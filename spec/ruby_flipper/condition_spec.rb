require 'spec_helper'

describe RubyFlipper::Condition do

  describe 'initializer' do

    it 'should store the name' do
      RubyFlipper::Condition.new(:condition_name).name.should == :condition_name
    end

    it 'should work with a single static condition' do
      RubyFlipper::Condition.new(:condition_name, true).conditions.should == [true]
    end

    it 'should work with multiple static conditions' do
      RubyFlipper::Condition.new(:condition_name, true, :development).conditions.should == [true, :development]
    end

    it 'should work with a dynamic condition' do
      condition = lambda { true }
      RubyFlipper::Condition.new(:condition_name, condition).conditions.should == [condition]
    end

    it 'should work with a combination of static and dynamic conditions' do
      condition = lambda { true }
      RubyFlipper::Condition.new(:condition_name, false, :live, condition).conditions.should == [false, :live, condition]
    end

    it 'should work with a combination of arrays and eliminate nil' do
      condition = lambda { true }
      RubyFlipper::Condition.new(:condition_name, [false, nil], condition).conditions.should == [false, condition]
    end

  end

  describe '#met?' do

    it 'should return false when not all conditions are met (with dynamic)' do
      RubyFlipper::Condition.new(:condition_name, true, lambda { false }).met?.should == false
    end

    it 'should return false when not all conditions are met (only static)' do
      RubyFlipper::Condition.new(:condition_name, false, true).met?.should == false
    end

    it 'should return true when all conditions are met' do
      RubyFlipper::Condition.new(:condition_name, true, true).met?.should == true
    end

  end

  describe '.condition_met?' do

    context 'with a symbol' do

      it 'should return the met? of the referenced condition' do
        RubyFlipper.conditions[:referenced] = RubyFlipper::Condition.new(:referenced, true)
        RubyFlipper::Condition.condition_met?(:referenced).should == true
      end

      it 'should raise an error when the referenced condition is not defined' do
        lambda { RubyFlipper::Condition.condition_met?(:referenced) }.should raise_error RubyFlipper::ConditionNotFoundError, 'condition referenced is not defined'
      end

    end

    {
      true       => true,
      "anything" => true,
      false      => false,
      nil        => false
    }.each do |condition, expected|

      it "should call a given proc and return #{expected} when it returns #{condition}" do
        RubyFlipper::Condition.condition_met?(lambda { condition }).should == expected
      end

      it "should call anything callable and return #{expected} when it returns #{condition}" do
        RubyFlipper::Condition.condition_met?(Struct.new(:call).new(condition)).should == expected
      end

      it "should return #{expected} when the condition is #{condition}" do
        RubyFlipper::Condition.condition_met?(condition).should == expected
      end

    end

  end

end
