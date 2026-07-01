/**
    NuMath Triangles

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.tri;
import numath.vector;
import numath.traits;
import numath.limits;
import numath.math;

/**
    A triangle.
*/
struct TriangleImpl(T)
if (is(T == VectorImpl!U, U...)) {
public:
@nogc:
    T p0;
    T p1;
    T p2;

    /**
        The in-center of the triangle.
    */
    @property T center() nothrow pure => (p0+p1+p2)/3;

    /**
        The sign (winding order) of the triangle.
    */
    @property float sign() nothrow pure {
        alias T3 = VectorImpl!(T.VT, 3);
        T3 u = T3(p1 - p0, 0);
        T3 v = T3(p2 - p0, 0);
        return -cast(float)cross(u, v).z;
    }

    /**
        Gets the barycentric coordinates of the given point.

        Params:
            pt = The point to check.

        Returns:
            The barycentric coordinates in relation to each
            vertex of the triangle.
    */
    vec3 barycentric(T pt) nothrow pure {
        T v0 = p1 - p0;
        T v1 = p2 - p0;
        T v2 = pt - p0;

        float d00 = dot(v0, v0);
        float d01 = dot(v0, v1);
        float d11 = dot(v1, v1);
        float d20 = dot(v2, v0);
        float d21 = dot(v2, v1);

        float invDen = 1.0 / (d00 * d11 - d01 * d01);
        float v = (d11 * d20 - d01 * d21) * invDen;
        float w = (d00 * d21 - d01 * d20) * invDen;
        return vec3(
            1.0 - v - w,
            v,
            w,
        );
    }

    /**
        Whether the triangle contains the given point.

        Params:
            pt = The point to check.
        
        Returns:
            $(D true) if the given point lies within this
            triangle, $(D false) otherwise.
    */
    bool contains(T pt) nothrow pure {
        if (pt == p0 || pt == p1 || pt == p2)
            return true;

        float d1 = typeof(this)(pt, p0, p1).sign;
        float d2 = typeof(this)(pt, p1, p2).sign;
        float d3 = typeof(this)(pt, p2, p0).sign;
        return (
            ((d1 < 0) || (d2 < 0) || (d3 < 0)) &&
            ((d1 > 0) || (d2 > 0) || (d3 > 0))
        );
    }
}

alias tri2f = TriangleImpl!(vec2);
alias tri3f = TriangleImpl!(vec3);

@("barycentric")
unittest {
    tri2f tri = tri2f(
        vec2(  0, 0), 
        vec2(0.5, 1), 
        vec2(  1, 0)
    );

    // Barycentric center coordinate.
    enum BC_CENTER = 1.0/3.0;

    assert(tri.barycentric(vec2(0.5, 0.5)) == vec3(0.25, 0.5, 0.25));
    assert(tri.barycentric(tri.center).isAlmost(vec3(BC_CENTER, BC_CENTER, BC_CENTER)));
}

@("contains")
unittest {
    tri2f tri = tri2f(
        vec2(  0, 0), 
        vec2(0.5, 1), 
        vec2(  1, 0)
    );

    assert(tri.contains(vec2(0.5, 0.5)));
    assert(tri.contains(vec2(0, 0)));
    assert(!tri.contains(vec2(-1, 0.5)));
}