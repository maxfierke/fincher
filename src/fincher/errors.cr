module Fincher
  class Error < Exception
  end

  class StrategyNotFeasibleError < ::Fincher::Error
  end

  class StrategyDoesNotExistError < ::Fincher::Error
  end

  class UnknownKeyError < ::Fincher::Error
  end

  class UnknownKeymapError < ::Fincher::Error
  end
end
