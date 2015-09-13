
cat(paste0("\nCorrect classifications in the traing set: ",format(train.correctness*100,digits=4),"%\n"))
cat(paste0("Correct classifications in the test set: ",format(test.correctness*100,digits=4),"%\n"))
readkey()

cat(paste0("\nDetails of classifications in the traing set:\n"))
cat(paste0("a) case of -1: \n"))
print(minus1.check.train)
cat(paste0("b) case of 0: \n"))
print(zero.check.train)
cat(paste0("c) case of 1: \n"))
print(plus1.check.train)
readkey()

cat(paste0("\nDetails of classifications in the test set:\n"))
cat(paste0("a) case of -1: \n"))
print(minus1.check.test)
cat(paste0("b) case of 0: \n"))
print(zero.check.test)
cat(paste0("c) case of 1: \n"))
print(plus1.check.test)
readkey()

print(lda_formula)
readkey()
# show column names and their ordinality sorted by "importance" 
print(ranking.DDA)
readkey()
# show "important" column names and their ordinality 
print(most.relevant)
readkey()
# show avg. values for each "important" column/variable for all predicted classes 
print(lda.results)
