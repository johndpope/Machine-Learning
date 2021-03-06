__author__ = 'NishantNath'

# !/usr/bin/env python
'''
Using : Python 2.7+ (backward compatibility exists for Python 3.x if separate environment created)
Required files : hdf5_getters.py
Required packages : numpy, pandas, matplotlib, sklearn

Steps:
1.

# Uses Simple PCA to find the most important features
# Uses Simple PCA Iteratively to find performance based on number of components
'''

import pandas
import matplotlib.pyplot as mpyplot
import pylab
import numpy
from itertools import cycle

def plot_2D(data, target, target_names):
    colors = cycle('rgbcmykw')
    target_ids = range(len(target_names))
    mpyplot.figure()
    for i, c, label in zip(target_ids, colors, target_names):
        mpyplot.scatter(data[target == i, 0], data[target == i, 1],c=c, label=label)
    mpyplot.legend()
    # mpyplot.show(p)


# [0: 'CLASSICAL', 1: 'METAL', 2: 'HIPHOP', 3: 'DANCE', 4: 'JAZZ']
# [5:'FOLK', 6: 'SOUL', 7: 'ROCK', 8: 'POP', 9: 'BLUES']

col_input=['genre', 'year', 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7', 'col8', 'col9', 'col10', 'col11', 'col12', 'col13', 'col14', 'col15', 'col16', 'col17', 'col18', 'col19', 'col20', 'col21', 'col22', 'col23', 'col24', 'col25', 'col26', 'col27', 'col28', 'col29', 'col30', 'col31', 'col32', 'col33', 'col34', 'col35', 'col36', 'col37', 'col38', 'col39', 'col40', 'col41', 'col42', 'col43', 'col44', 'col45', 'col46', 'col47', 'col48', 'col49', 'col50', 'col51', 'col52', 'col53', 'col54', 'col55', 'col56', 'col57', 'col58', 'col59', 'col60', 'col61', 'col62', 'col63', 'col64', 'col65', 'col66', 'col67', 'col68', 'col69', 'col70', 'col71', 'col72']
df_input = pandas.read_csv('pandas_output_missing_data_fixed.csv', header=None, delimiter = ",", names=col_input)

# range(2,74) means its goes from col 2 to col 73
df_input_data = df_input[list(range(2, 74))]
df_input_target = df_input[list(range(0, 1))]

colors = numpy.random.rand(len(df_input_target))

# Simple PCA
from sklearn.decomposition import PCA
pca = PCA(n_components=6) #from optimal pca components chart n_components=6
pca.fit(df_input_data)

# Relative weights on features
print pca.explained_variance_ratio_
print pca.components_

# performance of number of components vs variance
pca2 = PCA().fit(df_input_data)

# Plotting Simple PCA
mpyplot.figure(1)
p1 = mpyplot.plot(numpy.cumsum(pca2.explained_variance_ratio_))
mpyplot.xlabel('number of components')
mpyplot.ylabel('cumulative explained variance')
mpyplot.show(p1)

# Reduced Feature Set
df_input_data_reduced = pca.transform(df_input_data)

# Plotting Reduced Feature Set
mpyplot.figure(2)
p2 = mpyplot.scatter(df_input_data_reduced[:, 0], df_input_data_reduced[:, 1], c=colors)
mpyplot.colorbar(p2)
mpyplot.show(p2)

# Plotting in 2D - fix this
mpyplot.figure(3)
plot_2D(df_input_data_reduced, df_input_target, pandas.unique(df_input_target))