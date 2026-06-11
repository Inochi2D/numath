/**
    NuMath Basic Math

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.math;
import numath.traits;
import nu = nulib.math;

/**
    Computes the square root of the given value.

    Params:
        x = The value
    
    Returns:
        The square root of $(D x).
*/
alias sqrt = nu.sqrt;

/**
    Computes sine of the given value.

    Params:
        x = The value
    
    Returns:
        The sine of $(D x).
*/
alias sin = nu.sin;

/**
    Computes cosine of the given value.

    Params:
        x = The value
    
    Returns:
        The cosine of $(D x).
*/
alias cos = nu.cos;

/**
    Computes tangent of the given value.

    Params:
        x = The value
    
    Returns:
        The tangent of $(D x).
*/
alias tan = nu.tan;

/**
    Computes arc-sine of the given value.

    Params:
        x = The value
    
    Returns:
        The arc-sine of $(D x).
*/
alias asin = nu.asin;

/**
    Computes arc-cosine of the given value.

    Params:
        x = The value
    
    Returns:
        The arc-cosine of $(D x).
*/
alias acos = nu.acos;

/**
    Computes arc-tangent of the given value.

    Params:
        x = The value
    
    Returns:
        The arc-tangent of $(D x).
*/
alias atan = nu.atan;

/**
    Computes arc-tangent of the given value, using signs to determine quadrant.

    Params:
        y = value
        x = value
    
    Returns:
        The arc-tangent of $(D y / x).
*/
alias atan2 = nu.atan2;

/**
    Computes hyperbolic sine of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic sine of $(D x).
*/
alias sinh = nu.sinh;

/**
    Computes hyperbolic cosine of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic cosine of $(D x).
*/
alias cosh = nu.cosh;

/**
    Computes hyperbolic tangent of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic tangent of $(D x).
*/
alias tanh = nu.tanh;

/**
    Computes hyperbolic arc-sine of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic arc-sine of $(D x).
*/
alias asinh = nu.asinh;

/**
    Computes hyperbolic arc-cosine of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic arc-cosine of $(D x).
*/
alias acosh = nu.acosh;

/**
    Computes hyperbolic arc-tangent of the given value.

    Params:
        x = The value
    
    Returns:
        The hyperbolic arc-tangent of $(D x).
*/
alias atanh = nu.atanh;

/**
    Determines whether the given value is a finite number.

    Params:
        x   = The value to check
    
    Returns:
        $(D true) if $(D x) is a finite, valid number,
        $(D false) otherwise.
*/
alias isFinite = nu.isFinite;

/**
    &pi; (3.141592...)
*/
alias PI = nu.PI;

/**
    Converts the given angle in degrees to radians.

    Params:
        angle = The angle to convert.

    Returns:
        The angle in radians. 
*/
pragma(inline, true)
inout(T) radians(T)(inout(T) angle) @trusted @nogc nothrow pure
if (__traits(isFloating, T)) {
    return angle * (PI / 180.0);
}

/**
    Converts the given angle in radians to degrees.

    Params:
        angle = The angle to convert.

    Returns:
        The angle in degrees. 
*/
pragma(inline, true)
inout(T) degrees(T)(inout(T) angle) @trusted @nogc nothrow pure 
if (__traits(isFloating, T)) {
    return angle * (180.0 / PI);
}

/**
    Returns the smaller of the 2 given scalar values.

    Params:
        rhs = value
        lhs = value
    
    Returns:
        The smallest of the 2 given values.
*/
T min(T)(T lhs, T rhs) @trusted @nogc nothrow pure {
    return lhs < rhs ? lhs : rhs;
}

/**
    Returns the larger of the 2 given scalar values.

    Params:
        rhs = value
        lhs = value
    
    Returns:
        The largest of the 2 given values.
*/
T max(T)(T lhs, T rhs) @trusted @nogc nothrow pure {
    return lhs > rhs ? lhs : rhs;
}

/**
    Clamps scalar value into the given range.

    Params:
        value   = The value to clamp,
        min_    = The minimum value
        max_    = The maximum value.
    
    Returns:
        $(D value) clamped between $(D min_) and $(D max_),
        equivalent of $(D min(max(value, min_), max_))
*/
T clamp(T)(T value, T min_, T max_) @trusted @nogc nothrow pure {
    return min(max(value, min_), max_);
}

/**
    Linearly interpolates between $(D a) and $(D b)

    Params:
        a = The first value to interpolate
        b = The second value to interpolate
        t = The interpolation step from 0..1
    
    Returns:
        The interpolated value between $(D a) and $(D b)
*/
T lerp(T, FT)(T a, T b, FT t) @trusted @nogc nothrow pure
if (__traits(isFloating, FT)) {
    return a * (1 - t) + b * t;
}

/**
    Quadilaterally interpolates between $(D p0) and $(D p2),
    with $(D p1) as a control point.

    Params:
        p0 = The first value to interpolate
        p1 = The control value for the curve.
        p2 = The second value to interpolate
        t = The interpolation step from 0..1
    
    Returns:
        The interpolated value between $(D p0) and $(D p2)
*/
T quad(T, FT)(T p0, T p1, T p2, FT t) @trusted @nogc nothrow pure
if (__traits(isFloating, FT)) {
    FT tm = 1.0 - t;
    FT a = tm * tm;
    FT b = 2.0 * tm * t;
    FT c = t * t;

    return a * p0 + b * p1 + c * p2;
}

/**
    Interpolates between $(D p0) and $(D p3), using a cubic
    spline with $(D p1) and $(D p2) as control points.

    Params:
        p0 = The first value to interpolate
        p1 = The first control value for the curve.
        p2 = The second control value for the curve.
        p3 = The second value to interpolate
        t = The interpolation step from 0..1
    
    Returns:
        The interpolated value between $(D p0) and $(D p3)
*/
pragma(inline, true)
T cubic(T, FT)(T p0, T p1, T p2, T p3, FT t) @trusted @nogc nothrow pure
if (__traits(isFloating, FT)) {
    T a = -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3;
    T b = p0 - 2.5 * p1 + 2 * p2 - 0.5 * p3;
    T c = -0.5 * p0 + 0.5 * p2;
    T d = p1;
    
    return a * (t ^^ 3) + b * (t ^^ 2) + c * t + d;
}

/**
    Modulates the given value, preserving sign bit.

    Params:
        value   = The value to modulate.
        delta   = The modulation delta.

    Returns:
        The modulated value.
*/
pragma(inline, true)
T mod(T)(T value, T delta) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.mod(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.mod(value);
    }
}

/**
    Gets the absolute (positive) value for the given value.

    Params:
        value = the value to get the absolute value for.    

    Returns:
        The absolute value of the given value, if the value is not finite
        the return value is undefined.
*/
pragma(inline, true)
T abs(T)(T value) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.abs(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.abs(value);
    }
}

/**
    Copies the sign-bit(s) from one value to another.

    Params:
        to =    The value to copy to
        from =  The value to copy from
    
    Returns:
        The value of $(D to) with the sign bit flipped
        to match $(D from).
*/
pragma(inline, true)
T copysign(T)(T to, T from) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            to.data[i] = cast(T.VT)nu.copysign(to.data[i], cast(T.VT)from.data[i]);
        }
        return to;
    } else {
        return nu.copysign(to, from);
    }
}

/**
    Computes the nearest integer value lower in magnitude than
    the given value.

    Params:
        value = The value
    
    Returns:
        The nearest integer value lower in magnitude than $(D value).
*/
pragma(inline, true)
T trunc(T)(T value) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.trunc(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.trunc(value);
    }
}

/**
    Computes the nearest integer value, rounded away from 0.

    Params:
        value = Input value
    
    Returns:
        The nearest integer value to $(D x).
*/
pragma(inline, true)
T round(T)(T value) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.round(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.round(value);
    }
}

/**
    Computes the nearest integer value lower than the given value.

    Params:
        value = Input value
    
    Returns:
        The nearest integer value lower than $(D x).
*/
pragma(inline, true)
T floor(T)(T value) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.floor(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.floor(value);
    }
}

/**
    Computes the nearest integer value lower than the given value.

    Params:
        value = Input value
    
    Returns:
        The nearest integer value lower than $(D x).
*/
pragma(inline, true)
T ceil(T)(T value) @trusted @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.ceil(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.ceil(value);
    }
}