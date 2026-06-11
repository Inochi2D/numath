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
import numem.core.math;
import nu = nulib.math;
import numath.vector;

/**
	Gets whether type $(D T) is a scalar (numeric) 
    type.	
*/
enum isScalar(T) = __traits(isScalar, T);

/**
    Gets whether type $(D T) is a linear algebra
    type.
*/
enum isLinalg(T) =
    isVector!T;

/**
    Returns the smaller of the 2 given scalar values.

    Params:
        rhs = value
        lhs = value
    
    Returns:
        The smallest of the 2 given values.
*/
T min(T)(T lhs, T rhs) @nogc nothrow pure {
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
T max(T)(T lhs, T rhs) @nogc nothrow pure {
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
T clamp(T)(T value, T min_, T max_) @nogc nothrow pure {
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
T lerp(T, FT)(T a, T b, FT t) @nogc nothrow pure
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
T quad(T, FT)(T p0, T p1, T p2, FT t) @nogc nothrow pure
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
T cubic(T, FT)(T p0, T p1, T p2, T p3, FT t) @nogc nothrow pure
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
T mod(T)(T value, T delta) @nogc nothrow pure {
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
T abs(T)(T value) @nogc nothrow pure {
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
T copysign(T)(T to, T from) @safe @nogc nothrow pure {
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
T trunc(T)(T value) @nogc nothrow pure {
    static if (isLinalg!T) {
        static foreach(i; 0..T.data.length) {
            value.data[i] = cast(T.VT)nu.trunc(cast(real)value.data[i]);
        }
        return value;
    } else {
        return nu.trunc(value);
    }
}