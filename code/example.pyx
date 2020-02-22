from cython.parallel import prange, parallel
from libcpp.vector cimport vector
from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from libcpp.set cimport set

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
        cdef int current_str_pos = 0
        cdef char *substring
        
        regex_res = regexec(&self.regex_obj, stringbytes, 1, regmatch_obj, 0)
        while regex_res == 0:
            substring = <char *> malloc((regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so+1) * sizeof(char))
            substring[regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so] = 0
            strncpy(substring, stringbytes+current_str_pos+regmatch_obj[0].rm_so, regmatch_obj[0].rm_eo-regmatch_obj[0].rm_so)
            
            results.push_back(<string> substring)
            free(substring)
            
            current_str_pos += regmatch_obj[0].rm_eo
            regex_res = regexec(&self.regex_obj, stringbytes + current_str_pos, 1, regmatch_obj, 0)
            
        return results

cpdef set[string] vectorize(str patern, list STRINGS):
    cdef vector[string] results
    cdef char* PAT = <char *> malloc((len(patern)+1) * sizeof(char))
    PAT[len(patern)] = 0
    
    strncpy(PAT, patern.encode('utf-8'), len(patern))
    
    cdef vector[char*] cpp_words = [word.encode('utf-8') for word in STRINGS]
    
    reg = regex_cpp(PAT)
    free(PAT)
    
    cdef long i = 0
    cdef long length = cpp_words.size()
    
    cdef set[string] answers
    cdef long j = 0

    for i in range(length):
        results = reg.findall(cpp_words[i])
        for j in range(results.size()):
            answers.insert(results[j])
            
    
    return answers

cpdef set[string] vectorize_para(str patern, list STRINGS, long num_threads):
    cdef vector[string] results
    cdef char* PAT = <char *> malloc((len(patern)+1) * sizeof(char))
    PAT[len(patern)] = 0
    
    strncpy(PAT, patern.encode('utf-8'), len(patern))
    
    cdef vector[char*] cpp_words = [word.encode('utf-8') for word in STRINGS]
    
    reg = regex_cpp(PAT)
    free(PAT)
    
    cdef long i = 0
    cdef long length = cpp_words.size()
    
    cdef set[string] answers
    cdef long j = 0

    with nogil, parallel(num_threads=num_threads):
        for i in prange(length, schedule='static', chunksize=1):
            results = reg.findall(cpp_words[i])
            for j in prange(results.size()):
                answers.insert(results[j])
            
    
    return answers
    
    