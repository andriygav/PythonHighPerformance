import re
import numpy as np
cimport numpy as np
np.import_array()

token_pattern = re.compile(r"(?u)\b\w\w+\b")

class CythonVectorizer:
    def __init__(self):
        self.WordToInt = dict()
        pass
    
    def split_sent(self, sent):
        return token_pattern.findall(sent)
    
    def fit(self, corpus):
        for sent in corpus:
            words = self.split_sent(sent)
            for word in words:
                if word not in self.WordToInt:
                    self.WordToInt[word] = len(self.WordToInt)
        return
    
    def get_feature_names(self):
        return list(self.WordToInt.keys())
    
    def transform(self, corpus):
        transformed = np.zeros([len(corpus), len(self.WordToInt)], dtype=np.int64)
        for i, sent in enumerate(corpus):
            words = self.split_sent(sent)
            row = transformed[i]
            LocalVocab = dict()
            for word in words:
                if word in self.WordToInt:
                    ind = self.WordToInt[word]
                    if ind not in LocalVocab:
                        LocalVocab[ind] = 1
                    else:
                        LocalVocab[ind] += 1
                    
            for ind in LocalVocab:
                row[ind]=LocalVocab[ind];
                    
        return transformed
    
    def fit_transform(self, corpus):
        self._fit(corpus)
        return self._transform(corpus)




cdef class CythonTypedVectorizer:
    cdef dict WordToInt
    def __cinit__(self):
        self.WordToInt = dict()
        pass
        
    cdef list split_sent(self, str sent):
        return token_pattern.findall(sent)
    
    cpdef void fit(self, list corpus):
        cdef str word, sent
        cdef list words
        for sent in corpus:
            words = self.split_sent(sent)
            for word in words:
                if word not in self.WordToInt:
                    self.WordToInt[word] = len(self.WordToInt)
        return
    
    def get_feature_names(self):
        return list(self.WordToInt.keys())
    
    cpdef np.ndarray transform(self, list corpus):
        cdef np.ndarray row
        cdef dict LocalVocab
        cdef str word, sent
        cdef int i, ind
        cdef list words
        cdef np.ndarray transformed = np.zeros([len(corpus), len(self.WordToInt)], dtype=np.int64)
        for i, sent in enumerate(corpus):
            words = self.split_sent(sent)
            row = transformed[i]
            LocalVocab = dict()
            for word in words:
                if word in self.WordToInt:
                    ind = self.WordToInt[word]
                    if ind not in LocalVocab:
                        LocalVocab[ind] = 1
                    else:
                        LocalVocab[ind] += 1
                    
            for ind in LocalVocab:
                row[ind]=LocalVocab[ind];
                    
        return transformed
    
    def fit_transform(self, list corpus):
        self._fit(corpus)
        return self._transform(corpus)