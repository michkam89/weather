Temperature changes in Warsaw 2004-2019
================

Load data
=========

Data was downloaded manually from <https://dane.imgw.pl/> and I stored them in 'data-raw' folder. Here are the dimensions of obtained data frame:

    ## [1] 140256    107

The data set contained over 140000 rows and 107 columns. Unfortunately tables did not contain column names, so I needed to enter them manually ( I will skip that ugly part).

This is all about temperature so let's select the right columns and translate them to English.

Explore data
============

Missing values
--------------

naniar package is nice for missing data visualization.

And this is great as we have a complete data set! Let's explore it further.

Temperature values distribution
-------------------------------

<img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-6-1.png" style="display: block; margin: auto;" /> That's quite interesting. We see a bimodal distribution across most of the years (summer and winter? what about spring and autumn? do we still have 4 seasons?). 2012 looks like it had the most moderate temperatures as it is flat at the top. Anyway, let's split it by seasons. Let's assume that winter is 21-Dec - 20 Mar, spring 21-Mar - 20 Jun, summer 21-Jun - 20-Sept, Autumn 21-Sept - 20-Dec

<img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-7-1.png" style="display: block; margin: auto;" /> It looks like summer is the most stable season. There is a lot of variation in other seasons across the years. How it will look like when we split it by year: <img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-8-1.png" style="display: block; margin: auto;" /> Red vertical line indicates the median values per season of each year.

Trend analysis (seasons)
------------------------

It's difficult to see the trend on the charts above. Let's plot median values for each season each year: <img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-9-1.png" style="display: block; margin: auto;" /> Yep, the median temperature of all the seasons generally increases in time. Here is the plot with all data points for reference and a boxplot:

    ## Loading required package: grid

<img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-10-1.png" style="display: block; margin: auto auto auto 0;" />

Compare trends (seasons)
------------------------

The way to check which season temperature is increasing faster is to compare betas (slope angle) of linear model. Here are the betas for each season: <img src="temp_waw_eda_files/figure-markdown_github/unnamed-chunk-11-1.png" style="display: block; margin: auto;" /> Winter and spring are warming at the fastest pace. Around 0.16 and 0.15 degrees of Celcius per year. Autumn is the most stable but still warming.
