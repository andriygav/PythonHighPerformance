# cythonExample

## Базовый пример использования Cython
### Описание функций для иследования
В данном пункте приведем пример простой функции на языке python. В качестве функции рассматривалась функция, которая суммирует числа от 0 до N. В эксперименте сравнивается скорость работы данной функции в следующих случаях: 
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
### Вычислительный эксперимент
Для сравнения рассматривается N = 10000000 для всех моделей, а также каждая функция вызывается 200 раз для усреднения результата.
### Результаты
| Функция  | Время |
| ------------- | ------------- |
| Func  | 619 ms  |
| CythonFunc  | 439 ms  |
| CythonTypedFunc  | 0.172 ms |

## Список источников
* Kurt W. Smith. Cython: A Guide for Python Programmers. Sebastopol: O’Reilly, 2015.
