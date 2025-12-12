# Complex numbers

## Overview

Implementation complex numbers for Lua. Overload basic operators and mathematic functions. Compatibility with Lua 5.1+.

## Library constants

``` lua
complex.i -> complex
```
Imaginary unit.

``` lua
complex.e -> complex
complex.pi -> complex
complex.tau -> complex
```
Mathematic constants as complex numbers.

``` lua
complex.FMT.imaginary_char -> string
```
Character for printing imaginary unit.

``` lua
complex.FMT.format_spec_char -> 'f'|'g'|'G'|'e'|'E'|'a'|'A'
complex.FMT.format_sign_char -> nil|' '|'+'
```
Format specefication character for type and sign behaviour in `complex.tostring`.

``` lua
complex.FMT.epsilon -> number
```
Enough close to zero value.

## Constructors

``` lua
complex.new(real?: number, imag?: number) -> complex
complex.polar(r?: number, phi?: number) -> complex
```
Creation from cartesian or polar coordinates.

``` lua
complex.type(value: any) -> "integer"|"float"|"complex"|nil
```
Equivalent of function `math.type`.

``` lua
complex.tocomplex(value: any) -> complex
```
Convert any value to complex number.
If value not table nor number, then return NaN + NaNi.

## Access to value

``` lua
complex.real -> number
complex.imag -> number
```
Field with real and imaginary parts of complex number.

## Metamethods

``` lua
complex.__unm(z: complex) -> complex
```
Negation a complex number.

``` lua
complex.__add(lhs: complex|number, rhs: complex|number) -> complex
complex.__sub(lhs: complex|number, rhs: complex|number) -> complex
complex.__mul(lhs: complex|number, rhs: complex|number) -> complex
complex.__div(lhs: complex|number, rhs: complex|number) -> complex
complex.__pow(lhs: complex|number, rhs: complex|number) -> complex
```
Basic operations (`+`, `-`, `*`, `/`, `^`) with complex numbers.

## Conversion to string

``` lua
complex.tostring(z: complex, prec?: integer) -> string
```
Convert to string with precision after float point.

``` lua
complex.__tostring(z: complex) -> string
```
Implicit call method `complex.tostring` with `nil` arguments.

## Only complex number methods

``` lua
complex.round(z: complex, prec?: integer) -> complex
```
Apply `round` function to both fields.

``` lua
complex.conj(z: complex) -> complex
```
Returns conjugation of complex number.

``` lua
complex.norm(z: complex) -> number
```
Returns norm of complex number.

``` lua
complex.abs(z: complex) -> number
```
Returns absolute value of complex number.

``` lua
complex.arg(z: complex) -> number
```
Returns argument of complex number in range (-pi, pi].

``` lua
complex.crd(z: complex) -> number, number
```
Returns real and imaginary parts

``` lua
complex.plr(z: complex) -> number, number
```
Retunrs absolute value and argument together.

## Exponential and logarithm function

``` lua
complex.exp(z: complex|number) -> complex
```
Returns exponent (`e^z`) of complex number.

``` lua
complex.log(z: complex|number, base?: complex|number) -> complex
```
Returns logarithm of complex number with `base`.

## Roots

``` lua
complex.sqrt(z: complex|number) -> complex
```
Returns one value of square root of complex number.

``` lua
complex.roots(z: complex|number, n: integer) -> complex[]
```
Returns list of values of nth-root of complex number.

``` lua
complex.quadratic(a: complex|number, b: complex|number, c: complex|number) -> complex, complex
```
Solving quadratic equation (`az^2 + bz + c = 0`).

``` lua
complex.cubic(a: complex|number, b: complex|number, c: complex|number, d: complex|number) -> complex, complex, complex
```
Solving cubic equation (`az^3 + bz^2 + cz + d = 0`).

## Trigonometric functions

``` lua
complex.sin(z: complex|number) -> complex
complex.cos(z: complex|number) -> complex
complex.tan(z: complex|number) -> complex
complex.cot(z: complex|number) -> complex
complex.sec(z: complex|number) -> complex
complex.csc(z: complex|number) -> complex
```
Trigonometric functions for complex numbers.

``` lua
complex.asin(z: complex|number) -> complex
complex.acos(z: complex|number) -> complex
complex.atan(z: complex|number) -> complex
complex.acot(z: complex|number) -> complex
complex.asec(z: complex|number) -> complex
complex.acsc(z: complex|number) -> complex
```
Inverse trigonometric functions for complex numbers.

## Hyperbolic functions

``` lua
complex.sinh(z: complex|number) -> complex
complex.cosh(z: complex|number) -> complex
complex.tanh(z: complex|number) -> complex
complex.coth(z: complex|number) -> complex
complex.sech(z: complex|number) -> complex
complex.csch(z: complex|number) -> complex
```
Hyperbolic functions for complex numbers.

``` lua
complex.asinh(z: complex|number) -> complex
complex.acosh(z: complex|number) -> complex
complex.atanh(z: complex|number) -> complex
complex.acoth(z: complex|number) -> complex
complex.asech(z: complex|number) -> complex
complex.acsch(z: complex|number) -> complex
```
Inverse hyperbolic functions for complex numbers.

## Gamma-function

``` lua
complex.gamma(z: complex|number) -> complex
```
Returns value of Gamma-function of `z`.