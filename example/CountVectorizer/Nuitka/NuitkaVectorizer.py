import numpy as np
import re

token_pattern = re.compile(r"(?u)\b\w\w+\b")
class NuitkaVectorizer:
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