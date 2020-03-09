from numba import jit, njit, prange

@jit
def NumbaFunc(N):
    ret = 0
    for n in range(N):
        ret += n
    return ret

@njit(parallel=True)
def NumbaOpenMPFunc(N):
    ret = 0
    for n in prange(N):
        ret += n
    return ret