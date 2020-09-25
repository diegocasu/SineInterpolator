from math import pi, sin
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import statsmodels.api as sm
import numpy as np
import scipy.stats
import json



def parse_results():
    max_error = float("-inf")
    average_error = [0, 0]

    phase_value = []
    interpolated_sine = []

    with open("results.txt", "r") as file:
        for line in file.readlines():
            data = json.loads(line)

            phase_value.append(data["INPUT"])
            interpolated_sine.append(data["OUTPUT"])

            abs_difference = abs(sin(data["INPUT"]) - data["OUTPUT"])
            average_error[0] += abs_difference
            average_error[1] += 1

            if abs_difference > max_error:
                max_error = abs_difference

    return max_error, average_error, phase_value, interpolated_sine


def parse_interpolated_sine():
    phase_value = []
    interpolated_sine = []

    dummy = []

    with open("results.txt", "r") as file:
        for line in file.readlines():
            data = json.loads(line)
            phase_value.append(data["INPUT"])
            interpolated_sine.append(data["OUTPUT"])

            dummy.append((data["INPUT_BIT"]))

    print(dummy[32768])

    return phase_value, interpolated_sine


def plot_interpolated_sine(phase_value, interpolated_sine):
    figure = plt.figure(figsize=(13.66, 7.68))
    plot_axes = plt.gca()
    plot_axes.set_ylabel(r'sin(x)', fontsize=14, labelpad=10, rotation=90)
    plot_axes.set_xlabel(r'x', fontsize=14, labelpad=10)

    plot_axes.plot(phase_value, interpolated_sine, marker="", lw=2, color="cornflowerblue",
                   label="Interpolated sine")

    plot_axes.xaxis.set_major_locator(ticker.MultipleLocator(base=0.5))
    plot_axes.yaxis.set_major_locator(ticker.MultipleLocator(base=0.25))

    plt.margins(0)
    plt.legend(loc="upper left", prop={'size': 14})

    plt.savefig("InterpolatedSine.png", format="png", dpi=300, bbox_inches='tight')
    plt.draw()
    plt.show(block=True)


def plot_difference(phase_value, interpolated_sine):
    figure = plt.figure(figsize=(13.66, 7.68))
    plot_axes = plt.gca()
    plot_axes.set_ylabel(r'sin(x)', fontsize=14, labelpad=10, rotation=90)
    plot_axes.set_xlabel(r'x', fontsize=14, labelpad=10)

    difference = np.abs(np.sin(phase_value) - np.array(interpolated_sine))

    plot_axes.plot(phase_value, np.sin(phase_value), marker="", lw=2, color="darkorange",
                  label="Mathematical library sine")

    plot_axes.plot(phase_value, difference, marker="o", lw=0, color="crimson",
                  label="Error")

    plot_axes.xaxis.set_major_locator(ticker.MultipleLocator(base=0.5))
    plot_axes.yaxis.set_major_locator(ticker.MultipleLocator(base=0.25))

    plt.margins(0)
    plt.legend(loc="upper left", prop={'size': 14})

    plt.savefig("Difference.png", format="png", dpi=300, bbox_inches='tight')
    plt.draw()
    plt.show(block=True)


def linear_regression_analysis(x_vector, y_vector):
    numpy_x = np.array(x_vector)
    numpy_y = np.array(y_vector)

    numpy_x = sm.add_constant(numpy_x)  # To add an intercept (offset) in the model
    regression_results = sm.OLS(numpy_y, numpy_x).fit()  # Dependent variable y as first argument

    # Slope, offset, R^2
    return regression_results.params[1], regression_results.params[0], regression_results.rsquared


def plot_difference_distribution(phase_value, interpolated_sine):
    difference = np.abs(np.sin(phase_value) - np.array(interpolated_sine))
    ordered_statistics = sorted(difference)

    quantile_number = np.arange(1, len(difference) + 1, 1)
    quantile_number = (quantile_number - 0.5) / len(difference)
    theoretical_quantiles = scipy.stats.uniform.ppf(quantile_number).tolist()

    slope, offset, rsquared = linear_regression_analysis(theoretical_quantiles, ordered_statistics)

    # Compute the regression line
    regression_x = np.linspace(theoretical_quantiles[0], theoretical_quantiles[-1])
    regression_y = regression_x * slope + offset

    offset_sign = 'x ' if offset < 0 else 'x +'
    regr_equation = r'$y = ' + str(round(slope, 4)) + offset_sign + str(
        round(offset, 4)) + '$' + '\n' + r'$R^2 = ' + str(round(rsquared, 4)) + '$'

    # Plot
    figure = plt.figure(figsize=(13.66, 7.68))
    plot_axes = plt.gca()
    plot_axes.set_ylabel("Error", fontsize=14, labelpad=10, rotation=90)
    plot_axes.set_xlabel("Uniform quantile", fontsize=14, labelpad=10)

    # QQ points
    plot_axes.plot(theoretical_quantiles, ordered_statistics, marker="o", lw=0,
                   color="cornflowerblue")
    # Regression line
    plot_axes.plot(regression_x, regression_y, linestyle="--",
                        linewidth=2,
                        label=regr_equation, color="black")

    plt.margins(0)
    plt.legend(loc="upper left", prop={'size': 14})

    plt.savefig("QQ.png", format="png", dpi=300, bbox_inches='tight')
    plt.draw()
    plt.show(block=True)


def main():
    LSB_input = pi/(2**15 - 1)
    LSB_rom = 1/(2**8 - 1)

    max_error, average_error, phase_value, interpolated_sine  = parse_results()

    plot_interpolated_sine(phase_value, interpolated_sine)
    plot_difference(phase_value, interpolated_sine)
    plot_difference_distribution(phase_value, interpolated_sine)

    print("MAX ERROR: " + str(max_error))
    print("AVERAGE ERROR: " + str(average_error[0]/average_error[1]))


if __name__ == "__main__":
    main()
