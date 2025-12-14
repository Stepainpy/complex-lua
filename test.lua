local complex = require "complex"

local z = complex.new(3, 4)
local w = complex.new(2, 5)
local v = complex.new(7, 1)
local u = complex.new(6, 3)

local OK   = "\x1b[32m OK \x1b[0m"
local FAIL = "\x1b[31mFAIL\x1b[0m"
local env_tbl = {
    z = z, w = w, v = v, u = u,
    tostring = tostring,
    complex = complex,
    rad = math.rad,
    deg = math.deg,
}

---@param code string
---@param name string
---@param expected any[]
local function run_test(code, name, expected)
    local func, errmsg = load(code, "runtest", 't', env_tbl)
    local ok = true

    io.stdout:write('- [')
    if not func then
        io.stdout:write(FAIL)
    else
        local received = {pcall(func)}
        local status = received[1]
        table.remove(received, 1)

        if not status then
            ok, errmsg = false, received[1] --[[@as string]]
        else
            for i = 1, #expected do
                if expected[i] ~= received[i] then
                    errmsg = "'"..tostring(expected[i])..
                        "' != '"..tostring(received[i]).."'"
                    ok = false
                    break
                end
            end
        end
        io.stdout:write(ok and OK or FAIL)
    end
    io.stdout:write('] ', name)
    if errmsg then io.stdout:write(' (', errmsg, ')') end
    io.stdout:write('\n')
end

print "[#] Constructors"

run_test([[
    local a = complex.new(3, 4)
    local b = complex.polar(1, 1)
    return a.real, a.imag, b.real, b.imag
]], "Constructor from pair of numbers", {
    3, 4, math.cos(1), math.sin(1)
})
run_test([[
    return
        complex.type(80085),
        complex.type(42.69),
        complex.type(  z  ),
        complex.type("yes")
]], "Type function", {"integer", "float", "complex", nil})
run_test([[
    local a = complex.tocomplex(1)
    local b = complex.tocomplex("yes")
    return
        complex.tocomplex(z),
        complex.tocomplex({real = 3, imag = 4}),
        a.real, a.imag, not b
]], "Conversion to complex", {z, z, 1, 0, true})

print "[#] Access to fields"

run_test([[
    local a = complex.new(3, 4)
    return a.real, a.imag
]], "Get real and imaginary parts", {3, 4})

print "[#] Conversion to string"

run_test([[
    local a = complex.polar(1, rad(45))
    return tostring(z), a:tostring(5)
]], "Simple convert", {"3 + 4i", "0.70711 + 0.70711i"})
run_test([[
    complex.FMT.format_sign_char = ' '
    complex.FMT.imaginary_char = 'j'
    local str = tostring(z)
    complex.FMT.format_sign_char = nil
    complex.FMT.imaginary_char = 'i'
    return str
]], "Change format settings", {" 3 + 4j"})

print "[#] Operator metamethods"

run_test([[
    return z == z, z == w
]], "Equation (x == y)", {true, false})
run_test([[
    local a = -z
    return a.real, a.imag
]], "Negation (-x)", {-3, -4})
run_test([[
    local a = z + w
    return a.real, a.imag
]], "Addition (x + y)", {5, 9})
run_test([[
    local a = z - w
    return a.real, a.imag
]], "Substraction (x - y)", {1, -1})
run_test([[
    local a = z * w
    return a.real, a.imag
]], "Multiplication (x * y)", {-14, 23})
run_test([[
    local a = z / w
    return a.real, a.imag
]], "Division (x / y)", {26/29, -7/29})
run_test([[
    local a = z ^ w
    return a:tostring(5)
]], "Power (x ^ y)", {"-0.21525 - 0.11124i"})

print "[#] Only complex functions"

run_test([[
    local a = complex.new(10.4, 10.5):round()
    return a.real, a.imag
]], "Round", {10, 11})
run_test([[
    local a = z:conj()
    return a.real, a.imag
]], "Conjugate", {3, -4})
run_test([[ return z:norm() ]], "Norm", {25})
run_test([[ return z:abs() ]], "Absolute value", {5})
run_test([[
    return
        deg(( complex.i):arg()),
        deg((-complex.i):arg())
]], "Argumnet", {90, -90})
run_test([[ return z:crd() ]], "Cartesian coordinates", {3, 4})
run_test([[
    return complex.new(-1):plr()
]], "Polar coordinates", {1, math.pi})

print "[#] Exponential and logarithm function"

run_test([[
    return z:exp():tostring(5)
]], "Exponent", {"-13.12878 - 15.20078i"})
run_test([[
    local  ln  = z:log(  ):tostring(5)
    local  lg  = z:log(10):tostring(5)
    local log2 = z:log( 2):tostring(5)
    local logw = z:log(w ):tostring(5)
    return ln, lg, log2, logw
]], "Logarithm", {
    "1.60944 + 0.92730i", "0.69897 + 0.40272i",
    "2.32193 + 1.33780i", "0.89698 - 0.08337i"
})

print "[#] Root functions"

run_test([[
    local a = z:sqrt()
    local b = complex.sqrt(-4)
    return a.real, a.imag, b.real, b.imag
]], "Square root", {2, 1, 0, 2})
run_test([[
    local r = complex.new(1):roots(4)
    return
        tostring(r[1]), tostring(r[2]),
        tostring(r[3]), tostring(r[4])
]], "nth-root", {
    "1.0 + 0i", "0 + 1.0i", "-1.0 + 0i", "0 - 1.0i"
})
run_test([[
    local x1, x2 = complex.quadratic(0.5, -3, 2.5)
    local z1, z2 = complex.quadratic(z, w, v)
    return x1.real, x2.real, z1:tostring(5), z2:tostring(5)
]], "Solving quadratic equation", {
    1, 5, "0.03661 + 0.88908i", "-1.07661 - 1.16908i"
})
run_test([[
    local x1, x2, x3 = complex.cubic(0.25, 0.75, -1.5, -2)
    local y1, y2, y3 = complex.cubic(1, 0, 0, -1)
    local z1, z2, z3 = complex.cubic(z, w, v, u)
    return
        tostring(x1.real), tostring(x2.real), tostring(x3.real),
        y1:tostring(5), y2:tostring(5), y3:tostring(5),
        z1:tostring(5), z2:tostring(5), z3:tostring(5)
]], "Solving cubic equation", {'-4.0', '2.0', '-1.0',
    "-0.50000 - 0.86603i", "1.00000 + 0.00000i", "-0.50000 + 0.86603i",
    "0.41401 + 1.08744i", "-0.49414 - 1.01255i", "-0.95987 - 0.35489i"
})

print "[#] Trigonometric functions"

run_test([[
    local sin = z:sin():tostring(5)
    local cos = z:cos():tostring(5)
    local tan = z:tan():tostring(5)
    local cot = z:cot():tostring(5)
    local sec = z:sec():tostring(5)
    local csc = z:csc():tostring(5)
    return sin, cos, tan, cot, sec, csc
]], "Forward version", {
    "3.85374 - 27.01681i", "-27.03495 - 3.85115i",
    "-0.00019 + 0.99936i",  "-0.00019 - 1.00064i",
    "-0.03625 + 0.00516i",   "0.00517 + 0.03628i"
})
run_test([[
    local asin = z:asin():tostring(5)
    local acos = z:acos():tostring(5)
    local atan = z:atan():tostring(5)
    local acot = z:acot():tostring(5)
    local asec = z:asec():tostring(5)
    local acsc = z:acsc():tostring(5)
    return asin, acos, atan, acot, asec, acsc
]], "Inverse version", {
    "0.63398 + 2.30551i", "0.93681 - 2.30551i",
    "1.44831 + 0.15900i", "0.12249 - 0.15900i",
    "1.45205 + 0.16045i", "0.11875 - 0.16045i"
})

print "[#] Hyperbolic functions"

run_test([[
    local sinh = z:sinh():tostring(5)
    local cosh = z:cosh():tostring(5)
    local tanh = z:tanh():tostring(5)
    local coth = z:coth():tostring(5)
    local sech = z:sech():tostring(5)
    local csch = z:csch():tostring(5)
    return sinh, cosh, tanh, coth, sech, csch
]], "Forward version", {
    "-6.54812 - 7.61923i", "-6.58066 - 7.58155i",
     "1.00071 + 0.00491i",  "0.99927 - 0.00490i",
    "-0.06529 + 0.07522i", "-0.06488 + 0.07549i"
})
run_test([[
    local asinh = z:asinh():tostring(5)
    local acosh = z:acosh():tostring(5)
    local atanh = z:atanh():tostring(5)
    local acoth = z:acoth():tostring(5)
    local asech = z:asech():tostring(5)
    local acsch = z:acsch():tostring(5)
    return asinh, acosh, atanh, acoth, asech, acsch
]], "Inverse version", {
    "2.29991 + 0.91762i", "2.30551 + 0.93681i",
    "0.11750 + 1.40992i", "0.11750 - 0.16088i",
    "0.16045 - 1.45205i", "0.12125 - 0.15951i"
})

print "[#] Gamma-function"

run_test([[
    return complex.gamma(10):tostring()
]], "Use as factorial", {"362880.0 + 0i"})
run_test([[
    return z:gamma():tostring(5)
]], "With complex variable", {"0.00523 - 0.17255i"})