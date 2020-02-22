import numpy as np
import re
from tqdm import tqdm as tqdm
import time

with open('../data/wiki_short.txt', 'r') as f:
    lines = f.read().lower().splitlines()
    
import example

N = 100
M = 1
n = 0


############################################
# list_of_fit_times = []

# iterable = tqdm(range(M))
# for _ in iterable:
#     start = time.time()
#     ret = example.vectorizer_para("\w\w+", lines[n:N], 4, 1)
#     end = time.time()
    
#     list_of_fit_times.append(end-start)
    
#     iterable.set_postfix_str('(para={})'.format(np.mean(list_of_fit_times)))

# print('(para={})'.format(np.mean(list_of_fit_times)))


############################################
list_of_fit_times = []

iterable = tqdm(range(M))
for _ in iterable:
    start = time.time()
    ret = example.vectorizer("\w\w+", lines[n:N])
    end = time.time()
    
    list_of_fit_times.append(end-start)
    
    iterable.set_postfix_str('(one={})'.format(np.mean(list_of_fit_times)))

print('(one={})'.format(np.mean(list_of_fit_times)))