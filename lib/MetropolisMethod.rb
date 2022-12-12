class MetropolisMethod
  def self.calculate(function_callback, right_boundary, previous_x)
    gamma1 = rand(0.0..1.0)
    gamma2 = rand(0.0..1.0)
    delta = (1.0/3.0) * right_boundary
    x1 = previous_x + delta * (-1.0 + 2.0 * gamma1)

    if x1 < 0 || x1 > right_boundary
      return previous_x
    end

    previous_x_calculation = function_callback.call(previous_x)
    alpha = function_callback.call(x1) / previous_x_calculation

    if alpha >= 1.0 || alpha > gamma2
      return x1
    end

    previous_x
  end
end