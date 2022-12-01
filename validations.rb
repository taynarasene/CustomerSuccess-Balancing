module Validations
  class CustomerSuccessValidation
    LIMIT_SCORE = 10000
    LIMIT_ID = 1000
    LIMIT_SIZE = 1000

    def initialize(customer_success:, away_customer_success: [])
      @id = customer_success[:id]
      @score = customer_success[:score]
      @away_customer_success = away_customer_success
    end

    def valid?
      id_inside_limit? &&
        score_inside_limit? &&
        available_customer_success?
    end

    def self.allowed_size?(customer_success_list:)
      customer_success_list.size < LIMIT_SIZE
    end

    private

    attr_reader :id, :score, :away_customer_success

    def id_inside_limit?
      id.positive? && id < LIMIT_ID
    end

    def score_inside_limit?
      score.positive? && score < LIMIT_SCORE
    end

    def available_customer_success?
      return true if away_customer_success.empty?

      !away_customer_success.include?(id)
    end
  end

  class CustomerValidation
    LIMIT_SCORE = 100000
    LIMIT_ID = 1000000
    LIMIT_SIZE = 1000000

    def initialize(customer:)
      @id = customer[:id]
      @score = customer[:score]
    end

    def valid?
      id_inside_limit? && score_inside_limit?
    end

    def self.allowed_size?(customers:)
      customers.size < LIMIT_SIZE
    end

    private

    attr_reader :id, :score

    def id_inside_limit?
      id.positive? && id < LIMIT_ID
    end

    def score_inside_limit?
      score.positive? && score < LIMIT_SCORE
    end
  end
end