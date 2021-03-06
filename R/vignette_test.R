
library(ExomeDepth)
#source("R/class_definition.R")
#source("R/optimize_reference_set.R")


data <- read.table('../../CNVcalls/depth_Sergey_AROS.tab',
                   header = TRUE,
                   stringsAsFactors = FALSE)
data <- subset(data, ! (chromosome %in% c('X', 'Y')))



test <- new('ExomeDepth',
            test = data$camfid.033ahw_sorted_unique.bam,
            reference = data$camfid.035if_sorted_unique.bam,
            formula = 'cbind(test, reference) ~ 1',
            subset.for.speed = seq(1, nrow(data), 100))

show(test)



my.test <- data$camfid.034pc_sorted_unique.bam
my.reference.set <- as.matrix(data[, c('camfid.032KA_sorted_unique.bam', 'camfid.033ahw_sorted_unique.bam', 'camfid.035if_sorted_unique.bam')])
my.choice <- select.reference.set (test.counts = my.test, reference.counts = my.reference.set, bin.length = (data$end - data$start)/1000, n.bins.reduced = 10000)
#print(my.choice)

my.reference.selected <- apply(as.matrix( data[, my.choice$reference.choice] ), MAR = 1, FUN = sum)


test <- new('ExomeDepth',
            test = my.test,
            reference = my.reference.selected,
            formula = 'cbind(test, reference) ~ 1')

source('R/call_CNVs_method.R')
my.calls <- CallCNVs(test, transition.probability = 10^-4, chromosome = data$chromosome, start = data$start, end = data$end, name = data$exons)
print(head(my.calls$calls))
