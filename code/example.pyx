from cython.parallel import prange, parallel
from libcpp.vector cimport vector
from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from libcpp.set cimport set
import re

cdef extern from "regex.h" nogil:
    ctypedef struct regmatch_t:
        int rm_so
        int rm_eo
    ctypedef struct regex_t:
        pass
    int REG_EXTENDED
    int regcomp(regex_t* preg, const char* regex, int cflags)
    int regexec(const regex_t *preg, const char *string, size_t nmatch, regmatch_t pmatch[], int eflags)
    void regfree(regex_t* preg)
    
cdef extern from "<string.h>" nogil:
    char *strncpy (char *pto, const char *pfrom, size_t size)
    size_t strlen (const char *_str)

cdef class regex_cpp:
    cdef regex_t regex_obj
    
    def __cinit__(self, char* regex):
        regcomp(&self.regex_obj, regex, REG_EXTENDED)
        
    def __dealoc__(self):
        regfree(&self.regex_obj)
        
    cdef vector[string] findall(self, char* stringbytes) nogil:
        cdef regmatch_t regmatch_obj[1]
        cdef vector[string] results
        cdef int regex_res = 0
        cdef size_t current_str_pos = 0
        cdef size_t length = strlen(stringbytes)
        cdef char *substring
        
        regex_res = regexec(&self.regex_obj, stringbytes+current_str_pos, 1, regmatch_obj, 0)
        while regex_res == 0 and current_str_pos < length:
            if regmatch_obj[0].rm_so < 0:
                break
            if regmatch_obj[0].rm_eo < 0:
                break
            if current_str_pos+regmatch_obj[0].rm_so > length:
                break
            if regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so < 1:
                break
             
            substring = <char *> malloc((regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so+1) * sizeof(char))
            substring[regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so] = 0
            strncpy(substring, stringbytes+current_str_pos+regmatch_obj[0].rm_so, regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so)
            
            results.push_back(<string> substring)
            free(substring)
            
            current_str_pos += regmatch_obj[0].rm_eo
            regex_res = regexec(&self.regex_obj, stringbytes + current_str_pos, 1, regmatch_obj, 0)
            
        return results

cpdef set[string] vectorizer(str patern, list STRINGS):
    cdef vector[string] results
    
    cdef char* PAT = <char *> malloc((len(patern)+1) * sizeof(char))
    strncpy(PAT, patern.encode('utf-8'), len(patern))
    PAT[len(patern)] = 0
    

    cdef vector[char*] cpp_words
    cdef char* substring
    for word in STRINGS:
        substring = <char *> malloc((len(word)+1) * sizeof(char))
        substring[len(word)] = 0
        strncpy(substring, word.encode('utf-8'), len(word))
        cpp_words.push_back(substring)
    
    
    reg = regex_cpp(PAT)
    
    cdef size_t i = 0
    cdef size_t length = cpp_words.size()
    
    cdef set[string] answers
    cdef size_t j = 0

    for i in range(length):
        results = reg.findall(cpp_words[i])
        for j in range(results.size()):
            answers.insert(results[j])
            
    
    return answers

cpdef set[string] vectorizer_para(str patern, list STRINGS, long num_threads, long chunksize):
    cdef vector[string] results
    
    cdef char* PAT = <char *> malloc((len(patern)+1) * sizeof(char))
    strncpy(PAT, patern.encode('utf-8'), len(patern))
    PAT[len(patern)] = 0
    
    
    cdef vector[char*] cpp_words
    cdef char* substring
    for word in STRINGS:
        substring = <char *> malloc((len(word)+1) * sizeof(char))
        substring[len(word)] = 0
        strncpy(substring, word.encode('utf-8'), len(word))
        cpp_words.push_back(substring)
    
    reg = regex_cpp(PAT)
    
    cdef size_t i = 0
    cdef size_t length = cpp_words.size()
    
    cdef set[string] answers
    cdef size_t j = 0

    with nogil, parallel(num_threads=num_threads):
        for i in prange(length, schedule='static', chunksize=chunksize):
            results = reg.findall(cpp_words[i])
            for j in range(results.size()):
                with gil:
                    answers.insert(results[j])
            
    
    return answers
