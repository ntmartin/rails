# encoding: utf-8
require 'cases/helper'

require 'models/topic'
require 'models/person'

class ExclusionValidationTest < ActiveModel::TestCase

  def teardown
    Topic.reset_callbacks(:validate)
  end

  def test_validates_exclusion_of
    Topic.validates_exclusion_of( :title, :in => %w( abe monkey ) )

    assert Topic.new("title" => "something", "content" => "abc").valid?
    assert Topic.new("title" => "monkey", "content" => "abc").invalid?
  end

  def test_validates_exclusion_of_with_formatted_message
    Topic.validates_exclusion_of( :title, :in => %w( abe monkey ), :message => "option %{value} is restricted" )

    assert Topic.new("title" => "something", "content" => "abc")

    t = Topic.new("title" => "monkey")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["option monkey is restricted"], t.errors[:title]
  end

  def test_validates_exclusion_of_for_ruby_class
    Person.validates_exclusion_of :karma, :in => %w( abe monkey )

    p = Person.new
    p.karma = "abe"
    assert p.invalid?

    assert_equal ["is reserved"], p.errors[:karma]

    p.karma = "Lifo"
    assert p.valid?
  ensure
    Person.reset_callbacks(:validate)
  end

  def test_validates_exclusion_of_with_lambda
    Topic.validates_exclusion_of :title, :in => lambda{ |topic| topic.author_name == "sikachu" ? %w( monkey elephant ) : %w( abe wasabi ) }

    p = Topic.new
    p.title = "elephant"
    p.author_name = "sikachu"
    assert p.invalid?

    p.title = "wasabi"
    assert p.valid?
  end

  def test_validates_exclustion_with_invalid_lambda_return
    Topic.validates_exclusion_of :title, :in => lambda{ |topic| false }

    p = Topic.new
    p.title = "wasabi"
    p.author_name = "sikachu"
    assert_raise(ArgumentError){ p.valid? }
  end

  def test_validates_inclusion_with_explicit_include
    range = (1..100)
    Topic.validates_exclusion_of :title, :in => range, :use_include => true
    range.expects(:include?).returns(false)

    t = Topic.new
    t.title = 102
    assert t.valid?
  end
end
