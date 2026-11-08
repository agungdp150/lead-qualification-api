class ScoringError < StandardError
  attr_reader :code, :status

  def initialize(code, message, status)
    @code, @status = code, status
    super(message)
  end
end
