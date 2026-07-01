/**
    NuMath Planes

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.plane;
import numath.vector;
import numath.traits;
import numath.limits;
import numath.math;

/**
    Gets whether the given type is a plane.
*/
enum isPlane(T) = is(T == PlaneImpl!U, U...);

/**
    A 3D plane.
*/
struct PlaneImpl(T) 
if (isVector!T && T.dimensions == 3) {
public:
@nogc nothrow:
    alias VT = T;
    alias PT = T.VT;

    union {
        struct {

            /**
                X-axis normal
            */
            PT x;
            
            /**
                Y-axis normal
            */
            PT y;
            
            /**
                Z-axis normal
            */
            PT z;
        }

        /**
            Normal direction.
        */
        VT normal;
    }

    /**
        The plane's distance.
    */
    PT d;

    /**
        Distance constant.
    */
    pragma(inline, true)
    @property PT distance() @safe const pure => d;

    /**
        Normalized plane.
    */
    @property typeof(this) normalized() @safe inout pure {
        PT det = 1.0 / normal.length;
        return typeof(this)(x*det, y*det, z*det, d*det);
    }

    /**
        Constructs a new plane.

        Params:
            x = X-axis normal
            y = Y-axis normal
            z = Z-axis normal
            d = The distance of the plane
    */
    this(PT x, PT y, PT z, PT d) @safe {
        this.x = x;
        this.y = y;
        this.z = z;
        this.d = d;
    }

    /**
        Constructs a new plane.

        Params:
            normal =    The normal of the plane
            d =         The distance of the plane.  
    */
    this(VT normal, PT d) @safe {
        this.normal = normal;
        this.d = d;
    }

    /**
        Gets the distance from the given point to this
        plane.

        Params:
            point = The point

        Returns:
            The distance between this plane and the point.
    */
    PT distance(VT point) @safe inout pure {
        return dot(point, normal) + d;
    }




    //
    //      OPERATOR OVERLOADS
    //

    /**
        Gets whether the given plane describes the same
        plane as this one.
    */
    bool opEquals(Y)(Y other) inout pure {
        return 
            (cast(PT)other.x == normal.x) & 
            (cast(PT)other.y == normal.y) & 
            (cast(PT)other.z == normal.z) & 
            (cast(PT)other.d == d);
    }
}