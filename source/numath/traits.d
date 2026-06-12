/**
    NuMath traits

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.traits;
import numath.vector;
import numath.matrix;
import nulib.math.fixed;

public import numem.core.traits;
public import numem.core.meta;

/**
    Gets whether type $(D T) is a scalar (numeric) 
    type.   
*/
enum isScalar(T) = 
    __traits(isScalar, T) || 
    isFixed!T;

/**
    Gets whether type $(D T) is a type that can represent
    decimal values.    
*/
enum isDecimal(T) =
    __traits(isFloating, T) ||
    isFixed!T;

/**
    Gets whether type $(D T) is a linear algebra
    type.
*/
enum isLinalg(T) =
    isVector!T || 
    isMatrix!T;