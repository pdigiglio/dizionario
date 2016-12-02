import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import numpy
import pandas
import pylab
import seaborn

from collections import Counter
from scipy.stats import norm

def histo_length(data):
    fig    = pylab.figure()
    length = fig.add_subplot(111)

    length.distplot(data[0], label="Word length")

    length.legend()
    length.set_title("")
    length.set_xlabel("Word length")
    length.set_ylabel("Frequency")


    plt.hist(data)


# -- Main function -------------------------
if __name__ == '__main__':

    data_file_names = [ "histoData.dat",
                        "histoDataInitials.dat" ]

    data_files      = []
    for file_name in data_file_names:
        data_files.append(pylab.loadtxt(file_name))


#    histo_length(data_files[0])
#    print (histogram)
#    exit()
#    histogram = Counter(data_files[0])

    shifted_data = []
    for d in data_files[0]:
        shifted_data.append(d - .5)

    
    min_value = min(data_files[0])
    max_value = max(data_files[0])
    bins = int(max_value - min_value) + 1
    lengths = seaborn.distplot(shifted_data, bins, kde=None)

    lengths.set_xlabel("Word length")
    lengths.xaxis.set_major_locator(plticker.MultipleLocator(base=1))

    lengths.set_ylabel("")
    lengths.yaxis.set_major_locator(plticker.MultipleLocator(base=2))

    lengths.set_title("Ignorance Histogram (lengths)")

    count = Counter(shifted_data)
    for i in count:
        print(i, count[i])

    pylab.show()
