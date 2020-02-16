# cythonExample

## Базовый пример использования Cython
### Описание функций для иследования
В данном пункте приведем пример простой функции на языке python. В качестве функции рассматривалась функция, которая суммирует числа от **0** до **N**. В эксперименте сравнивается скорость работы данной функции в следующих случаях: 
* ```FuncPypy(N)``` --- функция реализована на pypy; 
* ```Func(N)``` --- функция реализована на python без предварительной компиляции;
* ```CythonFunc(N)``` --- реализована на python но предварительно скомпилирована;
* ```CythonTypedFunc(N)``` --- реализована на cython с типизацией объектов.
```
def FuncPypy(N):
    ret = 0
    for n in range(N):
        ret += n
    return ret
    
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
Для сравнения рассматривается **N = 10000000** для всех моделей, а также каждая функция вызывается **200** раз для усреднения результата.
### Результаты
В данном простом примере получили следующие оценки времени работы функций:
| Реализация  | Время |
| ------------- | ------------- |
| Func  | 619 ms  |
| FuncPypy  | 16 ms  |
| CythonFunc  | 439 ms  |
| CythonTypedFunc  | 0.172 ms |

Весь код доступен по [ссылке](https://github.com/andriygav/cythonExample/blob/master/example/SimpleExample.ipynb) и [ссылке](https://github.com/andriygav/cythonExample/blob/master/example/SimpleExamplePypy.ipynb).

## Пример на основе CountVectorizer с пакета sklearn
### Описание функций для иследования
В данном пункте сравним скорости работы простого векторного представления предложений. В качестве базового решения выбран ```CountVectorizer``` из пакета ```sklearn```.

На основе ```CountVectorizer``` был написан сообвественый класс ```Vectorizer``` на python. Данный класс повторяет базовые возможности класса ```CountVectorizer```, такие как ```fit``` и ```transform```. Код доступен по [ссылке](https://github.com/andriygav/cythonExample/blob/master/example/CountVectorizer.ipynb) и [ссылке](https://github.com/andriygav/cythonExample/blob/master/example/CountVectorizerPypy.ipynb).

Сревнение производительности проводится для класса ```Vectorizer``` который работает в следующих случаях:
* ```VectorizerPyp()``` --- простая реализация на pypy3;
* ```Vectorizer()``` --- простая реалзиция на python без компиляции;
* ```CythonVectorizer()``` --- простая компиляция класса без использования типизации;
* ```CythonTypedVectorizer()``` --- компиляция класса ```Vectorizer``` с использованием типизации данных.
### Вычислительный эксперимент
В эксперименте сравнивается время метода ```fit```, а также метода ```transform``` для всех моделей. Для оценки времени производится усреднение по нескольким независимым вызовам данных методов. Каждый раз вызов метода ```fit``` производится на новом объекте рассматриваемого класса. Метод ```transform``` вызывается также каждый раз на новом объекте рассматриваемого класса после вызова метода ```fit```.
### Результаты
Оценка времени выполнялась для выборки, которая состояла из **79582** строк (**16.8mb** текста). Всего в данном тексте содержится **76777** различных токенов, которые были найдены всемы моделями и добавлены в словарь.

Для чистоты эксперимента время представленное в таблице является устредненным по **200** вызовам функции ```fit``` и **200** вызовам функции ```transform```.

| Реализация  | Время fit | Время transform |
| ------------- | ------------- | ------------- |
| CountVectorizer  | 1393 ms  | 2538 ms |
| Vectorizer  | 633 ms | 2121 ms |
| VectorizerPypy  | 372 ms | 3140 ms |
| CythonVectorizer  | 579 ms | 1964 ms |
| CythonTypedVectorizer  | 545 ms | 1955 ms |




## Список источников
* Kurt W. Smith. Cython: A Guide for Python Programmers. Sebastopol: O’Reilly, 2015.
