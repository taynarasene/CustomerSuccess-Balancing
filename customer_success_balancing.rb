require 'minitest/autorun'
require 'timeout'
require './validations.rb'

class CustomerSuccessBalancing

  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    available_customer_success
    available_customer
    sort_by_score
    balance_customer_success
    customer_success_with_most_customers
  end

  private 
  

  def available_customer_success
    @customer_success = @customer_success.select do |current_customer_success|
      customer_success_valid?(current_customer_success)
    end
  end
  
  def customer_success_valid?(current_customer_success)
    Validations::CustomerSuccessValidation.new(
      customer_success: current_customer_success,
      away_customer_success: @away_customer_success
    ).valid?
  end

  def available_customer
    @customers = @customers.select do |customer|
      customer_valid?(customer)
    end
  end

  def customer_valid?(customer)
    Validations::CustomerValidation.new(
      customer: customer
    ).valid?
  end


  def sort_by_score
    @customer_success = @customer_success.sort { |a,b| a[:score] <=> b[:score] }
    @customers = @customers.sort { |a,b| a[:score] <=> b[:score] }
  end

  def balance_customer_success
    generate_default_quantity_custumers
    @customers.each do |customer|
      selected_customer_success = assign_customer_to_customer_success_to_customer(customer)

      if selected_customer_success
        selected_customer_success[:total_customers] += 1
      end
    end
  end

  def generate_default_quantity_custumers
    @customer_success.each do |current_customer_success|
      current_customer_success[:total_customers] = 0
    end
  end

  def assign_customer_to_customer_success_to_customer(customer)
    @customer_success.find do |current_customer_success|
      current_customer_success[:score] >= customer[:score]
    end
  end

  def customer_success_with_most_customers
    @customer_success = @customer_success.sort { |a,b| -a[:total_customers] <=> -b[:total_customers] }
    if @customer_success[0][:total_customers] != @customer_success[1][:total_customers] or @customer_success.empty?
      return @customer_success[0][:id]
    end
    return 0
  end
end


class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
