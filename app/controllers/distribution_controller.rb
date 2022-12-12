require_relative '../../lib/ProbabilityDensityFunction'
require_relative '../../lib/GeneratorCore'
require_relative '../../lib/NeumannMethod'
require_relative '../../lib/MetropolisMethod'
require_relative '../../lib/PiecewiseApproximationMethod'
require_relative '../../lib/MethodCalculationUtils'

class DistributionController < ApplicationController
  def index
    generation_count = params['generation-count'] # 10000
    max_x = params['right-boundary']  # 3
    p1 = params['p1']       # sigma
    a2 = params['a2']       # mu
    b3 = params['b3']
    step = 0.1
    puts p1, a2, b3

    if generation_count && max_x && p1 && a2 && b3
      generation_count = generation_count.to_i
      max_x = max_x.to_f
      p1 = p1.to_f
      a2 = a2.to_f
      b3 = b3.to_f
    else
      return
    end

    if generation_count < 1 || max_x <= 0 || p1 <= 0 || a2 <= 0 || b3 <= 0
      return
    end

    generator = GeneratorCore.new(max_x, step, generation_count)
    total_generations_count = generator.get_total_generations_count   # 300 000

    pdf_calculation_lambda = -> (x) { ProbabilityDensityFunction.solve(p1, a2, b3, x) }
    pdf_mode_value = ProbabilityDensityFunction.mode(p1, a2, b3)
    pdf_mean_value = ProbabilityDensityFunction.mean(p1, a2, b3)
    pdf_variance_value = ProbabilityDensityFunction.variance(p1, a2, b3)
    pdf_deviation_value = ProbabilityDensityFunction.deviation(p1, a2, b3, total_generations_count)
    pdf_maximum_value = ProbabilityDensityFunction.maximum_value(p1, a2, b3)

    neumann_method_lambda = -> () { NeumannMethod.calculate(pdf_calculation_lambda, pdf_maximum_value, max_x) }

    previous_x_result = pdf_mode_value
    metropolis_method_lambda = -> () {
      calculation_result = MetropolisMethod.calculate(pdf_calculation_lambda, max_x, previous_x_result)
      previous_x_result = calculation_result
      calculation_result
    }

    piecewise_sum_h = PiecewiseApproximationMethod.calculate_sum_h(pdf_calculation_lambda, max_x)
    piecewise_approximation_lambda = -> () { PiecewiseApproximationMethod.calculate(pdf_calculation_lambda, max_x, piecewise_sum_h) }

    neumann_method_data = generator.generate(neumann_method_lambda)
    metropolis_method_data = generator.generate(metropolis_method_lambda)
    piecewise_approximation_data = generator.generate(piecewise_approximation_lambda)

    methods_calculation = MethodCalculationUtils.new

    neumann_method_expected = methods_calculation.get_mean(
      total_generations_count,
      neumann_method_data['sum'],
    )
    metropolis_method_expected = methods_calculation.get_mean(
      total_generations_count,
      metropolis_method_data['sum'],
    )
    piecewise_method_expected = methods_calculation.get_mean(
      total_generations_count,
      piecewise_approximation_data['sum'],
    )

    neumann_method_variance = methods_calculation.get_variance(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
    )
    metropolis_method_variance = methods_calculation.get_variance(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
    )
    piecewise_method_variance = methods_calculation.get_variance(
      total_generations_count,
      piecewise_approximation_data['sum'],
      piecewise_approximation_data['sum_squares'],
    )

    neumann_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
      )
    metropolis_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
      )
    piecewise_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      piecewise_approximation_data['sum'],
      piecewise_approximation_data['sum_squares'],
      )

    @calculation_result = {
      'options' => {
        'generationCount' => generation_count,
        'max_x' => max_x,
        'step' => step,
        'p1' => p1,
        'a2' => a2,
        'b3' => b3
      },
      'pdfMaxValue' => pdf_maximum_value,
      'pdfModeValue' => pdf_mode_value,
      'pdfMeanValue' => pdf_mean_value,
      'pdfVarianceValue' => pdf_variance_value,
      'pdfDeviationValue' => pdf_deviation_value,
      'neumannMethod' => neumann_method_data['frequencies'],
      'metropolisMethod' => metropolis_method_data['frequencies'],
      'piecewiseApproximationMethod' => piecewise_approximation_data['frequencies'],
      'neumannMethodExpectedValue' => neumann_method_expected,
      'metropolisMethodExpectedValue' => metropolis_method_expected,
      'piecewiseMethodExpectedValue' => piecewise_method_expected,
      'neumannMethodVariance' => neumann_method_variance,
      'metropolisMethodVariance' => metropolis_method_variance,
      'piecewiseMethodVariance' => piecewise_method_variance,
      'neumannMethodDeviation' => neumann_method_deviation,
      'metropolisMethodDeviation' => metropolis_method_deviation,
      'piecewiseMethodDeviation' => piecewise_method_deviation,
    }
  end
end
