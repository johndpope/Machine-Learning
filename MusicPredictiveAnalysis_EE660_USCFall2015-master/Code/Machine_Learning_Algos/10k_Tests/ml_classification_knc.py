# !/usr/bin/env python

__author__ = 'NishantNath'


'''
Using : Python 2.7+ (backward compatibility exists for Python 3.x if separate environment created)
Required files : hdf5_getters.py
Required packages : numpy, pandas, matplotlib, sklearn

Steps:
1.

# Uses k-nearest centroids for clustering
'''

import pandas
import matplotlib.pyplot as mpyplot
import pylab
import numpy
import sklearn

# [0: 'CLASSICAL', 1: 'METAL', 2: 'HIPHOP', 3: 'DANCE', 4: 'JAZZ']
# [5:'FOLK', 6: 'SOUL', 7: 'ROCK', 8: 'POP', 9: 'BLUES']

col_input=['genre', 'year', 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7', 'col8', 'col9', 'col10', 'col11', 'col12', 'col13', 'col14', 'col15', 'col16', 'col17', 'col18', 'col19', 'col20', 'col21', 'col22', 'col23', 'col24', 'col25', 'col26', 'col27', 'col28', 'col29', 'col30', 'col31', 'col32', 'col33', 'col34', 'col35', 'col36', 'col37', 'col38', 'col39', 'col40', 'col41', 'col42', 'col43', 'col44', 'col45', 'col46', 'col47', 'col48', 'col49', 'col50', 'col51', 'col52', 'col53', 'col54', 'col55', 'col56', 'col57', 'col58', 'col59', 'col60', 'col61', 'col62', 'col63', 'col64', 'col65', 'col66', 'col67', 'col68', 'col69', 'col70', 'col71', 'col72']
df_input = pandas.read_csv('pandas_output_missing_data_fixed.csv', header=None, delimiter = ",", names=col_input)

# range(2,74) means its goes from col 2 to col 73
df_input_data = df_input[list(range(2,74))].as_matrix() # test with few good features as determined through PCA?
df_input_target = df_input[list(range(0,1))].as_matrix()

colors = numpy.random.rand(len(df_input_target))

# splitting the data into training and testing sets
from sklearn.cross_validation import train_test_split
X_train, X_test, y_train, y_test = train_test_split(df_input_data, df_input_target.tolist())

# k-NN
from sklearn.neighbors.nearest_centroid import NearestCentroid
knc = NearestCentroid()
knc.fit(X_train[:],numpy.ravel(y_train[:]))
predicted = knc.predict(X_test)

print y_test[60:90] , len(y_test[60:90])
print predicted[60:90] , len(predicted[60:90])

print knc.classes_

# Prediction Performance Measurement
matches = (predicted == [item for sublist in y_test for item in sublist])
print matches.sum()
print len(matches)

print matches[10:50], len(matches[10:50])

print "Accuracy : ", (matches.sum() / float(len(matches)))

# # fix this metrics part later
# from sklearn import metrics
# print metrics.classification_report(y_test, predicted)
#
# print metrics.confusion_matrix(y_test, predicted)


# # use this in kmeans code somewhere ??
# >>> from sklearn.cluster import KMeans
# >>> from sklearn.metrics import pairwise_distances_argmin_min
# >>> X = np.random.randn(10, 4)
# >>> km = KMeans(n_clusters=2).fit(X)
# >>> closest, _ = pairwise_distances_argmin_min(km.cluster_centers_, X)
# >>> closest
# array([0, 8])
# The array closest contains the index of the point in X that is closest to each centroid. So X[0] is the closest point in X to centroid 0, and X[8] is the closest to centroid 1.


# see this for kcn recursive values
#     http://scikit-learn.org/stable/auto_examples/neighbors/plot_nearest_centroid.html