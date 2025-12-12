--[[ Localization global functions and values ]]--

local tostr = tostring
local tblconcat = table.concat
local gtype, mtype = type, math.type
local gsetmetatable = setmetatable
local ggetmetatable = getmetatable

local exp, log = math.exp, math.log
local sin, cos = math.sin, math.cos
local atan, sqrt = math.atan, math.sqrt
local floor, abs = math.floor, math.abs

local e, pi, tau = exp(1), math.pi, 2 * math.pi

--[[ Definition of class and settings ]]--

---Complex numbers and functions for them
---@class complex
---@field real number    real   part
---@field imag number imaginary part
---@operator unm(): complex
---@operator add(complex | number): complex
---@operator sub(complex | number): complex
---@operator mul(complex | number): complex
---@operator div(complex | number): complex
---@operator pow(complex | number): complex
local complex = {}
complex.__index = complex

complex.FMT = {
    ---@type 'f'|'g'|'G'|'e'|'E'|'a'|'A'
    format_spec_char = 'f',
    ---@type nil|' '|'+'
    format_sign_char = nil,
    ---@type string Usually `i` or `j`
    imaginary_char = 'i',
    ---@type number Enough close to zero
    epsilon = 1e-14
}

--[[ Constructors ]]--

---Constructor of complex number
---@param real? number
---@param imag? number
---@return complex
function complex.new(real, imag)
    return gsetmetatable({
        real = real or 0,
        imag = imag or 0
    }, complex)
end

---Constructor from polar coordinate
---@param  r ? number
---@param phi? number
---@return complex
function complex.polar(r, phi)
    return complex.new(
        (r or 0) * cos(phi or 0),
        (r or 0) * sin(phi or 0)
    )
end

---Equivalent of math.type
---@param value any
---@return "integer" | "float" | "complex" | nil
function complex.type(value)
    return mtype(value) --[[@as "integer" | "float"]] or
        ggetmetatable(value) == complex and "complex" or nil
end

---Convert any value to complex number
---@param value any
---@return complex
function complex.tocomplex(value)
    local mt = ggetmetatable(value)
    local ts = gtype(value)

        if mt == complex then
        return value
    elseif ts == "table" then
        return complex.new(value.real, value.imag)
    elseif ts == "number" then
        return complex.new(value, 0)
    else
        return complex.new(0/0, 0/0)
    end
end

--[[ Constants ]]--

---Imaginary unit
---@type complex
complex.i = complex.new(0, 1)

---Mathematic constant `e`
---@type complex
complex.e = complex.new(e)

---Mathematic constant `pi`
---@type complex
complex.pi = complex.new(pi)

---Mathematic constant `tau` (`2pi`)
---@type complex
complex.tau = complex.new(tau)

--[[ Converts to string ]]--

---Convert complex number to string with precision
---@param z complex
---@param prec? integer
---@return string
function complex.tostring(z, prec)
    if abs(z.real) < complex.FMT.epsilon then z.real = 0 end
    if abs(z.imag) < complex.FMT.epsilon then z.imag = 0 end
    local fmt = '%.'..(prec or '')..complex.FMT.format_spec_char
    local els, re, im = {}, z.real, z.imag

    if re >= 0 then els[#els + 1] = complex.FMT.format_sign_char end
    els[#els + 1] = prec and fmt:format(    re ) or tostr(    re )
    els[#els + 1] = im < 0 and ' - ' or ' + '
    els[#els + 1] = prec and fmt:format(abs(im)) or tostr(abs(im))
    els[#els + 1] = complex.FMT.imaginary_char

    return tblconcat(els)
end

---@return string
function complex:__tostring() return self:tostring() end

--[[ Metamethods ]]--

---Convert any value to real and imaginary parts
---@param value any
---@return number, number
local function toreimpair(value)
    local ts = gtype(value)
    if ts == "table" then
        return value.real, value.imag
    elseif ts == "number" then
        return value, 0
    else
        return 0/0, 0/0
    end
end

---@param z complex
---@return complex
function complex.__unm(z)
    return complex.new(-z.real, -z.imag)
end

---@param lhs complex | number
---@param rhs complex | number
---@return boolean
function complex.__eq(lhs, rhs)
    local x, y = toreimpair(lhs)
    local u, v = toreimpair(rhs)
    return x == u and y == v
end

---@param lhs complex | number
---@param rhs complex | number
---@return complex
function complex.__add(lhs, rhs)
    local x, y = toreimpair(lhs)
    local u, v = toreimpair(rhs)
    return complex.new(x + u, y + v)
end

---@param lhs complex | number
---@param rhs complex | number
---@return complex
function complex.__sub(lhs, rhs)
    local x, y = toreimpair(lhs)
    local u, v = toreimpair(rhs)
    return complex.new(x - u, y - v)
end

---@param lhs complex | number
---@param rhs complex | number
---@return complex
function complex.__mul(lhs, rhs)
    local x, y = toreimpair(lhs)
    if gtype(rhs) == "number" then
        return complex.new(x * rhs, y * rhs)
    else
        local u, v = toreimpair(rhs)
        return complex.new(
            x * u - y * v,
            x * v + y * u
        )
    end
end

---@param lhs complex | number
---@param rhs complex | number
---@return complex
function complex.__div(lhs, rhs)
    local x, y = toreimpair(lhs)
    if gtype(rhs) == "number" then
        return complex.new(x / rhs, y / rhs)
    else
        local u, v = toreimpair(rhs)
        return complex.new(
            (x * u + y * v) / (u ^ 2 + v ^ 2),
            (y * u - x * v) / (u ^ 2 + v ^ 2)
        )
    end
end

---@param lhs complex | number
---@param rhs complex | number
---@return complex
function complex.__pow(lhs, rhs)
    local r, phi = complex.tocomplex(lhs):plr()
    if gtype(rhs) == "number" then
        return complex.polar(r ^ rhs, phi * rhs)
    else
        return complex.exp(rhs * complex.new(log(r), phi))
    end
end

--[[ Only complex functions ]]--

---@param x number
---@param prec? integer
---@return number
local function round(x, prec)
    local shift = 10 ^ (prec or 0)
    return floor(x * shift + 0.5) / shift
end

---Round function for complex number
---@param z complex
---@param prec? integer
---@return complex
function complex.round(z, prec)
    return complex.new(
        round(z.real, prec),
        round(z.imag, prec)
    )
end

---Conjugation of complex number
---@param z complex
---@return complex
function complex.conj(z)
    return complex.new(z.real, -z.imag)
end

---Norm of complex number
---@param z complex
---@return number
function complex.norm(z)
    return z.real ^ 2 + z.imag ^ 2
end

---Absolute value of complex number
---@param z complex
---@return number
function complex.abs(z)
    return sqrt(z:norm())
end

---Argument of complex number
---@param z complex
---@return number
function complex.arg(z)
    return atan(z.imag, z.real)
end

---Cartesian coordinates of complex number
---@param z complex
---@return number, number
function complex.crd(z)
    return z.real, z.imag
end

---Polar coordinates of complex number
---@param z complex
---@return number, number
function complex.plr(z)
    return z:abs(), z:arg()
end

--[[ Exponential and logarithm function ]]--

---Complex exponent
---@param z complex | number
---@return complex
function complex.exp(z)
    local x, y = toreimpair(z)
    return complex.new(exp(x) * cos(y), exp(x) * sin(y))
end

---Complex logarithm
---@param z complex | number
---@param base? complex | number
---@return complex
function complex.log(z, base)
    z = complex.tocomplex(z)
    local n, phi = z:norm(), z:arg()
    if not base then
        return complex.new(log(n) / 2, phi)
    elseif gtype(base) == "number" then
        return complex.new(
            log(n, base) / 2,
            log(e, base) * phi
        )
    else
        return complex.log(z) / complex.log(base)
    end
end

--[[ Roots of complex number ]]--

---Complex square root
---@param z complex | number
---@return complex
function complex.sqrt(z)
    z = complex.tocomplex(z)
    return complex.new(
        sqrt(( z.real + z:abs()) / 2),
        sqrt((-z.real + z:abs()) / 2) * (z.imag < 0 and -1 or 1)
    )
end

---A number of nth-roots of complex number
---@param z complex | number
---@param n integer
---@return complex[]
function complex.roots(z, n)
    if mtype(n) ~= "integer" or n < 2 then return {} end
    z = complex.tocomplex(z)
    local sqrtr = z:abs() ^ (1/n)
    local phi_n = z:arg() / n
    local roots = {}
    for k = 0, n - 1, 1 do
        roots[#roots + 1] = complex.new(
            sqrtr * cos(phi_n + tau*k/n),
            sqrtr * sin(phi_n + tau*k/n)
        )
    end
    return roots
end

---Solving `az^2 + bz + c = 0`
---@param a complex | number
---@param b complex | number
---@param c complex | number
---@return complex, complex
function complex.quadratic(a, b, c)
    local D = complex.sqrt(b * b - a * c * 4)
    return (-b - D) / (a * 2), (-b + D) / (a * 2)
end

---Solving `az^3 + bz^2 + cz + d = 0`
---@param a complex | number
---@param b complex | number
---@param c complex | number
---@param d complex | number
---@return complex, complex, complex
function complex.cubic(a, b, c, d)
    local a3 = a * -3
    local d0 = b * b - a * c * 3
    local d1 = b * b * b * 2 - a * b * c * 9 + a * a * d * 27
    local C, d0C
    if d0 == 0 then
        C = complex.roots(d1, 3)
        d0C = {complex.new(), complex.new(), complex.new()}
    else
        C = ((d1 + complex.sqrt(d1 * d1 - d0 * d0 * d0 * 4)) / 2):roots(3)
        d0C = {d0 / C[1], d0 / C[2], d0 / C[3]}
    end
    return
        (C[1] + d0C[1] + b) / a3,
        (C[2] + d0C[2] + b) / a3,
        (C[3] + d0C[3] + b) / a3
end

--[[ Trigonometric functions ]]--

---Hyperbolic sine
---@param x number
---@return number
local function sinh(x)
    return (exp(x) - exp(-x)) / 2
end

---Hyperbolic cosine
---@param x number
---@return number
local function cosh(x)
    return (exp(x) + exp(-x)) / 2
end

---Sine of complex number
---@param z complex | number
---@return complex
function complex.sin(z)
    local x, y = toreimpair(z)
    return complex.new(sin(x) * cosh(y), cos(x) * sinh(y))
end

---Cosine of complex number
---@param z complex | number
---@return complex
function complex.cos(z)
    local x, y = toreimpair(z)
    return complex.new(cos(x) * cosh(y), -sin(x) * sinh(y))
end

---Tangent of complex number
---@param z complex | number
---@return complex
function complex.tan(z)
    local x, y = toreimpair(z)
    return complex.new(
        sin (2 * x) / (cos(2 * x) + cosh(2 * y)),
        sinh(2 * y) / (cos(2 * x) + cosh(2 * y))
    )
end

---Cotangent of complex number
---@param z complex | number
---@return complex
function complex.cot(z)
    local x, y = toreimpair(z)
    return complex.new(
        sin (2 * x) / -(cos(2 * x) - cosh(2 * y)),
        sinh(2 * y) /  (cos(2 * x) - cosh(2 * y))
    )
end

---Secant of complex number
---@param z complex | number
---@return complex
function complex.sec(z)
    local x, y = toreimpair(z)
    return complex.new(
        2 * cos(x) * cosh(y) / (cos(2 * x) + cosh(2 * y)),
        2 * sin(x) * sinh(y) / (cos(2 * x) + cosh(2 * y))
    )
end

---Cosecant of complex number
---@param z complex | number
---@return complex
function complex.csc(z)
    local x, y = toreimpair(z)
    return complex.new(
        2 * sin(x) * cosh(y) / -(cos(2 * x) - cosh(2 * y)),
        2 * cos(x) * sinh(y) /  (cos(2 * x) - cosh(2 * y))
    )
end

--[[ Inverse trigonometric functions ]]--

---Inverse sine of complex number
---@param z complex | number
---@return complex
function complex.asin(z)
    z = complex.tocomplex(z)
    return complex.i * complex.log(
        complex.sqrt(1 - z * z) - complex.new(-z.imag, z.real)
    )
end

---Inverse cosine of complex number
---@param z complex | number
---@return complex
function complex.acos(z)
    z = complex.tocomplex(z)
    return complex.i * complex.log(
        z - complex.i * complex.sqrt(1 - z * z)
    )
end

---Inverse tangent of complex number
---@param z complex | number
---@return complex
function complex.atan(z)
    z = complex.tocomplex(z)
    return complex.new(0, -0.5) * complex.log(
        (complex.i - z) / (complex.i + z)
    )
end

---Inverse cotangent of complex number
---@param z complex | number
---@return complex
function complex.acot(z)
    z = complex.tocomplex(z)
    return complex.new(0, -0.5) * complex.log(
        (z + complex.i) / (z - complex.i)
    )
end

---Inverse secant of complex number
---@param z complex | number
---@return complex
function complex.asec(z)
    z = complex.tocomplex(z)
    return complex.i * complex.log(
        1 / z - complex.i * complex.sqrt(1 - 1 / (z * z))
    )
end

---Inverse cosecant of complex number
---@param z complex | number
---@return complex
function complex.acsc(z)
    z = complex.tocomplex(z)
    return complex.i * complex.log(
        complex.sqrt(1 - 1 / (z * z)) - complex.i / z
    )
end

--[[ Hyperbolic functions ]]--

---Hyperbolic sine of complex number
---@param z complex | number
---@return complex
function complex.sinh(z)
    z = complex.tocomplex(z)
    return (complex.exp(z) - complex.exp(-z)) / 2
end

---Hyperbolic cosine of complex number
---@param z complex | number
---@return complex
function complex.cosh(z)
    z = complex.tocomplex(z)
    return (complex.exp(z) + complex.exp(-z)) / 2
end

---Hyperbolic tangent of complex number
---@param z complex | number
---@return complex
function complex.tanh(z)
    z = complex.tocomplex(z)
    return (complex.exp(z * 2) - 1) / (complex.exp(z * 2) + 1)
end

---Hyperbolic cotangent of complex number
---@param z complex | number
---@return complex
function complex.coth(z)
    z = complex.tocomplex(z)
    return (complex.exp(z * 2) + 1) / (complex.exp(z * 2) - 1)
end

---Hyperbolic secant of complex number
---@param z complex | number
---@return complex
function complex.sech(z)
    local x, y = toreimpair(z)
    return complex.new(
        2 * cosh(x) * cos(y) /  (cosh(2 * x) + cos(2 * y)),
        2 * sinh(x) * sin(y) / -(cosh(2 * x) + cos(2 * y))
    )
end

---Hyperbolic cosecant of complex number
---@param z complex | number
---@return complex
function complex.csch(z)
    local x, y = toreimpair(z)
    return complex.new(
        2 * sinh(x) * cos(y) / -(cos(2 * y) - cosh(2 * x)),
        2 * cosh(x) * sin(y) /  (cos(2 * y) - cosh(2 * x))
    )
end

--[[ Inverse hyperbolic functions ]]--

---Inverse hyperbolic sine of complex number
---@param z complex | number
---@return complex
function complex.asinh(z)
    z = complex.tocomplex(z)
    return complex.log(z + complex.sqrt(z * z + 1))
end

---Inverse hyperbolic cosine of complex number
---@param z complex | number
---@return complex
function complex.acosh(z)
    z = complex.tocomplex(z)
    return complex.log(z + complex.sqrt(z * z - 1))
end

---Inverse hyperbolic tangent of complex number
---@param z complex | number
---@return complex
function complex.atanh(z)
    z = complex.tocomplex(z)
    return complex.log((1 + z) / (1 - z)) / 2
end

---Inverse hyperbolic cotangent of complex number
---@param z complex | number
---@return complex
function complex.acoth(z)
    z = complex.tocomplex(z)
    return complex.log((z + 1) / (z - 1)) / 2
end

---Inverse hyperbolic secant of complex number
---@param z complex | number
---@return complex
function complex.asech(z)
    z = complex.tocomplex(z)
    return complex.log(
        1 / z + complex.sqrt(1 / (z * z) - 1)
    )
end

---Inverse hyperbolic cosecant of complex number
---@param z complex | number
---@return complex
function complex.acsch(z)
    z = complex.tocomplex(z)
    return complex.log(
        1 / z + complex.sqrt(1 / (z * z) + 1)
    )
end

--[[ Gamma-function ]]--
-- For calculation use Lanczos approximation
-- with g = 8 and n = 12

local gammaf_sqrt_tau = complex.new(sqrt(tau))
local gammaf_p = {
    complex.new(    0.9999999999999999298     ),
    complex.new( 1975.3739023578852322        ),
    complex.new(-4397.3823927922428918        ),
    complex.new( 3462.6328459862717019        ),
    complex.new(-1156.9851431631167820        ),
    complex.new(  154.53815050252775060       ),
    complex.new(-   6.2536716123689161798     ),
    complex.new(    0.034642762454736807441   ),
    complex.new(-   7.477617197444297737700e-7),
    complex.new(    6.304125382185226426100e-8),
    complex.new(-   2.740571703568387748900e-8),
    complex.new(    4.048694881756760910100e-9)
}

---Gamma-function of complex number
---@param z complex | number
---@return complex
function complex.gamma(z)
    z = complex.tocomplex(z)
    if z.real < 0.5 then
        return complex.pi / (
            complex.sin(complex.pi * z) * complex.gamma(1 - z)
        )
    end

    z = z - 1
    local t = z + 8.5 --> t = z + g + 0.5
    local x = gammaf_p[1]
    for i = 2, #gammaf_p do
        x = x + gammaf_p[i] / (z + (i - 1))
    end

    return gammaf_sqrt_tau * t ^ (z + 0.5) * complex.exp(-t) * x
end

return complex