# cythonExample

## Базовый пример использования Cython
В данном пункте приведем пример простой функции на языке python. В качестве функции рассматривалась функция, которая суммирует числа от $0$ до $N$. В эксперименте сравнивается скорость работы данной функции в следующих случаях: 
* ```func(N)``` --- функция реализована на python без предварительной компиляции; 
* ```CythonFunc(N)``` --- реализована на python но предварительно скомпилирована;
* ```CythonTypedFunc(N)``` --- реализована на cython с типизацией объектов.
```
def Func(N):
    ret = 0
    for n in range(N):
        ret += n
    return ret
    
%%cython

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
```

## Список источников
* Kurt W. Smith. Cython: A Guide for Python Programmers. Sebastopol: O’Reilly, 2015.
