def CythonFunc(N):
    ret = 0
    for n in range(N):
        ret += n
    return ret

def CythonTypedFunc(int N):
    cdef long ret = 0
    cdef long n
    for n in range(N):
        ret += n
    return ret

from cython.parallel import prange
cpdef CythonOpenMPFunc(int N):
    cdef long ret = 0
    cdef long n
    for n in prange(N, nogil=True):
        ret += n
    return ret