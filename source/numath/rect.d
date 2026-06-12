/**
    NuMath Rectangles

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.rect;
import numath.vector;
import numath.traits;
import numath.limits;
import numath.math;

/**
    Gets whether the given type is a valid rectangle.   
*/
enum isRect(T) = is(T == RectImpl!U, U...);


/**
    A 2D Rectangle.    
*/
struct RectImpl(T)
if (isScalar!T) {
@safe pure nothrow:
public:
    union {

        struct {

            /**
                X coordinate of the rectangle.
            */
            T x = 0;

            /**
                Y coordinate of the rectangle.
            */
            T y = 0;

            /**
                Width of the rectangle.
            */
            T width = 0;

            /**
                Height of the rectangle.
            */
            T height = 0;
        }

        /**
            Linear view of the rectangle's data.
        */
        T[4] data;
    }

    /**
        The type of the rectangle's components
    */
    alias RT = T;

    /**
        A type representing a point in the rectangle.
    */
    alias PointT = VectorImpl!(T, 2);



    //
    //          SPECIAL ENUMERATIONS
    //

    /**
        An empty rectangle.
    */
    enum identity = typeof(this)(0, 0, 0, 0);


    //
    //          PROPERTIES
    //

    /**
        Pointer to the start of the vector's data.
    */
    @property const(T)* ptr() const => cast(const(T)*)data.ptr;

    /**
        Left coordinate of the rectangle
    */
    @property T left() const => x;

    /**
        Right coordinate of the rectangle
    */
    @property T right() const => x+width;

    /**
        Top coordinate of the rectangle
    */
    @property T top() const => y;

    /**
        Bottom coordinate of the rectangle
    */
    @property T bottom() const => y+height;

    /**
        The center of the rectangle
    */
    @property PointT center() const => PointT(this.x + (this.width/2), this.y + (this.height/2));

    /**
        The top-left corner of the rectangle
    */
    @property PointT corner() const => PointT(x, y);

    /**
        The extents of the rectangle
    */
    @property PointT extents() const => PointT(this.width, this.height);

    /**
        The UV coordinates of each corner.
    */
    @property VectorImpl!(T, 4) uvs() const => VectorImpl!(T, 4)(this.left, this.top, this.right, this.bottom);

    /**
        Gets whether this rectangle intersects another.

        Params:
            other = The other primitive to query against.

        Returns:
            $(D true) if the rectangle intersects $(D other),
            $(D false) otherwise.
    */
    bool intersects(Y)(inout(Y) other) const 
    if (isRect!Y) {
        return !(other.left >= this.right || other.right <= this.left || other.top >= this.bottom || other.bottom <= this.top);
    }

    /**
        Gets whether this rectangle intersects a vector

        Params:
            other = The other primitive to query against.

        Returns:
            $(D true) if the rectangle intersects $(D other),
            $(D false) otherwise.
    */
    bool intersects(Y)(inout(Y) other) const
    if (isVector!Y) {
        return !(other.x >= this.right || other.x <= this.left || other.y >= this.bottom || other.y <= this.top);
    }

    /**
        Displaces the rect by the specified amount
    */
    void displace(Y)(inout(Y) other) 
    if (isVector!Y && Y.dimensions == 2) {
        this.x += other.x;
        this.y += other.y;
    }

    /**
        Gets a rect that has been displaced by the specified amount
    */
    auto displaced(Y)(inout(Y) other) const
    if (isVector!Y && Y.dimensions == 2) {
        return typeof(this)(this.x+other.x, this.y+other.y, this.width, this.height);
    }

    /**
        Expands the rect by the specified amount from the center
    */
    void expand(Y)(inout(Y) other)
    if (isVector!Y && Y.dimensions == 2) {
        this.x -= other.x;
        this.y -= other.y;
        this.width += other.x*2;
        this.height += other.y*2;
    }

    /**
        Expands the rect by the specified amount from the corner
    */
    void expandSize(Y)(inout(Y) other) 
    if (isVector!Y && Y.dimensions == 2) {
        this.width += other.x;
        this.height += other.y;
    }

    /**
        Gets a rect that has been expanded by the specified amount from the center
    */
    auto expanded(Y)(inout(Y) other) const 
    if (isVector!Y && Y.dimensions == 2) {
        return typeof(this)(this.x-other.x, this.y-other.y, this.width+(other.x*2), this.height+(other.y*2));
    }

    /**
        Expands the rect by the specified amount from the corner
    */
    auto expandedSize(Y)(inout(Y) other) const
    if (isVector!Y && Y.dimensions == 2) {
        return typeof(this)(this.x, this.y, this.width+other.x, this.height+other.y);
    }

    /**
        Clips this rectangle with another.

        Params:
            other = The rectangle to clip with.

        Returns:
            A rectangle that represents the parts of the 
            2 rectangles which overlapped.
    */
    auto clipped(Y)(inout(Y) other)
    if (isRect!Y) {

        // Top Left
        Vector!(T, 2) tl = Vector!(T, 2)(
            other.left > this.left ? other.left : this.left,
            other.top > this.top ? other.top : this.top,
        );
        
        // Bottom Right
        Vector!(T, 2) br = Vector!(T, 2)(
            other.right < this.right ? other.right : this.right,
            other.bottom < this.bottom ? other.bottom : this.bottom,
        );

        return typeof(this)(
            tl.x,
            tl.y,
            br.x-tl.x,
            br.y-tl.y
        );
    }

    /**
        Clips this rectangle with another.

        Params:
            other = The rectangle to clip with.
    */
    void clip(Y)(inout(Y) other)
    if (isRect!Y) {
        this = this.clipped(other);
    }
}




//
//              TYPE DEFINITIONS
//

alias rect = RectImpl!(float);
alias rectd = RectImpl!(double);
alias recti = RectImpl!(int);