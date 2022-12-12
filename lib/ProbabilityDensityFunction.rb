class ProbabilityDensityFunction
  def self.solve(p1, a2, b3, x)
    square_root = 0.01 + (x * (1 - x))
    1 / (Math::PI * Math.sqrt(square_root))
  end

  def self.mode(p1, a2, b3)
    rand()
  end

  def self.maximum_value(p1, a2, b3)
    mode = mode(p1, a2, b3)
    ProbabilityDensityFunction.solve(p1, a2, b3, mode)
  end

  def self.mean  (p1, a2, b3)
    1/2
  end

  def self.variance(p1, a2, b3)
   1/8
  end

  def self.deviation(p1, a2, b3, generation_count)
    variance = ProbabilityDensityFunction.variance(p1, a2, b3)
    Math.sqrt(variance / generation_count)
  end
end


