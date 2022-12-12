class PiecewiseApproximationMethod
  @slices = 100

  def self.calculate(function_callback, right_boundary, sum_h)
    random = rand(0.0..1.0)

    x = 0
    p = 0.0
    (1..@slices).each do |i|
      x = i * (1.0 / @slices) * 1.0 * right_boundary
      p += function_callback.call(x) / sum_h
      break if random < p
    end

    delta = rand(0.0..1.0)

    x - delta * right_boundary / @slices
  end

  def self.calculate_sum_h(function_callback, right_boundary)
    sum_h = 0.0
    (1..@slices).each do |i|
      x = i * (1.0 / @slices) * 1.0 * right_boundary
      sum_h += function_callback.call(x)
    end

    sum_h
  end
end