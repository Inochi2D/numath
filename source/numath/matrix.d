/**
    NuMath Matrices

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.matrix;
import numath.vector;
import numath.traits;
import numath.limits;
import numath.math;

/**
    Gets whether the given type is a valid mathematic matrix.
*/
enum isMatrix(T) = is(T == MatrixImpl!U, U...);

/**
    Gets whether the 2 given matrix types are of the same size.
*/
enum isSizeCompatibleMatrices(MT1, MT2) = 
    (isMatrix!MT1 && isMatrix!MT2) && 
    (MT1.rows == MT2.rows) && 
    (MT1.columns == MT2.columns);

/**
    A matrix.    
*/
struct MatrixImpl(T, int r_, int c_) 
if (isScalar!T) {
@nogc nothrow pure:
public:
    union {

        /**
            The data stored in the matrix, in linear form.
        */
        T[c_*r_] data = 0;

        /**
            The data stored in the matrix.
        */
        T[c_][r_] matrix;
    }

    /**
        The type of the matrix' components
    */
    alias MT = T;

    /**
        Amount of rows in the matrix.
    */
    enum rows = r_;

    /**
        Amount of columns in the matrix.
    */
    enum columns = c_;



    //
    //          SPECIAL ENUMERATIONS
    //
    static if (rows == columns) {
        
        /**
            Identity matrix.
        */
        enum MatrixImpl!(T, rows, columns) identity = {
            typeof(this) result = typeof(this)(0);
            static foreach(i; 0..columns)
                result.data[(rows*i)+i] = 1;
            return result;
        }();
    }




    //
    //          CREATION FUNCTIONS
    //
    static if (rows == columns) {

        /**
            Creates a translation matrix with the given arguments.

            Params:
                args = The translation in each axis.

            Returns:
                A translation matrix with the given values.
        */
        static auto translation(Args...)(Args args)
        if (allSatisfy!(isScalar, Args)) {
            typeof(this) result = typeof(this).identity;
            static foreach(i; 0..min(rows-1, args.length))
                result.data[(rows*i)+(columns-1)] = cast(T)args[i];

            return result;
        }

        /**
            Creates a translation matrix with the given vector.

            Params:
                vec = The translation vector

            Returns:
                A translation matrix with the given values.
        */
        static auto translation(Y)(inout(Y) vec)
        if (isVector!Y) {
            typeof(this) result = typeof(this).identity;
            static foreach(i; 0..min(rows-1, Y.dimensions))
                result.data[(rows*i)+(columns-1)] = cast(T)vec.data[i];

            return result;
        }

        /**
            Creates a scaling matrix with the given arguments.

            Params:
                args = The scaling amount on each axis.

            Returns:
                A scaling matrix with the given values.
        */
        static auto scaling(Args...)(Args args)
        if (allSatisfy!(isScalar, Args)) {
            typeof(this) result = typeof(this).identity;
            static foreach(i; 0..min(rows-1, Args.length))
                result.data[(rows*i)+i] = cast(T)args[i];

            return result;
        }

        /**
            Creates a scaling matrix with the given vector.

            Params:
                vec = The scaling vector

            Returns:
                A scaling matrix with the given values.
        */
        static auto scaling(Y)(inout(Y) vec)
        if (isVector!Y) {
            typeof(this) result = typeof(this).identity;
            static foreach(i; 0..min(rows-1, Y.dimensions))
                result.data[(rows*i)+i] = cast(T)vec.data[i];

            return result;
        }

        //
        //          3D FLOAT SPECIFICS
        //
        static if (rows >= 3 && __traits(isFloating, T)) {

            /**
                Creates a rotation matrix that rotates along the given plane.

                Params:
                    plane = The 3D plane of rotation, expressed as a normal vector.
                    alpha = The amount to rotate by, in radians.

                Returns:
                    A rotation matrix for the given plane and alpha.
            */
            static auto rotation(VectorImpl!(MT, 3) plane, MT alpha) {
                typeof(this) result = typeof(this).identity;
                
                // Normalize the plane unit vector, if needed.
                if (plane.length != 1)
                    plane = plane.normalized;

                MT vcos = cos(alpha);
                MT vsin = sin(alpha);
                VectorImpl!(MT, 3) temp = (1 - vcos)*plane;
                result.matrix[0][0] = cast(MT)(vcos + temp.x * plane.x);
                result.matrix[0][1] = cast(MT)(       temp.x * plane.y + vsin * plane.z);
                result.matrix[0][2] = cast(MT)(       temp.x * plane.z - vsin * plane.y);
                result.matrix[1][0] = cast(MT)(       temp.y * plane.x - vsin * plane.z);
                result.matrix[1][1] = cast(MT)(vcos + temp.y * plane.y);
                result.matrix[1][2] = cast(MT)(       temp.y * plane.z + vsin * plane.x);
                result.matrix[2][0] = cast(MT)(       temp.z * plane.x + vsin * plane.y);
                result.matrix[2][1] = cast(MT)(       temp.z * plane.y - vsin * plane.x);
                result.matrix[2][2] = cast(MT)(vcos + temp.z * plane.z);
                return result;
            }

            /**
                Creates a rotation about the X axis (YZ plane)

                Params:
                    alpha = The amount to rotate by, in radians.

                Returns:
                    A matrix encoding a rotation in the YZ plane.
            */
            static auto xRotation(MT alpha) {
                typeof(this) result = typeof(this).identity;
                MT vcos = cast(MT)cos(alpha);
                MT vsin = cast(MT)sin(alpha);

                result.matrix[1][1] = vcos;
                result.matrix[1][2] = -vsin;
                result.matrix[2][1] = vsin;
                result.matrix[2][2] = vcos;
                return result;
            }

            /**
                Creates a rotation about the X axis (XZ plane)

                Params:
                    alpha = The amount to rotate by, in radians.

                Returns:
                    A matrix encoding a rotation in the XZ plane.
            */
            static auto yRotation(MT alpha) {
                typeof(this) result = typeof(this).identity;
                MT vcos = cast(MT)cos(alpha);
                MT vsin = cast(MT)sin(alpha);

                result.matrix[0][0] = vcos;
                result.matrix[0][2] = vsin;
                result.matrix[2][0] = -vsin;
                result.matrix[2][2] = vcos;
                return result;
            }

            /**
                Creates a rotation about the Z axis (XY plane)

                Params:
                    alpha = The amount to rotate by, in radians.

                Returns:
                    A matrix encoding a rotation in the XY plane.
            */
            static auto zRotation(MT alpha) {
                typeof(this) result = typeof(this).identity;
                MT vcos = cast(MT)cos(alpha);
                MT vsin = cast(MT)sin(alpha);

                result.matrix[0][0] = vcos;
                result.matrix[0][1] = -vsin;
                result.matrix[1][0] = vsin;
                result.matrix[1][1] = vcos;
                return result;
            }
        } 

        //
        //          4D FLOAT SPECIFICS
        //
        static if (rows == 4 && __traits(isFloating, T)) {
            
            /**
                Creates a perspective matrix.

                Params:
                    width =     Width of the viewport
                    height =    Height of the viewport
                    fov =       The field of view, in radians.
                    near =      The distance of the z near plane.
                    far =       The distance of the z far plane.
            */
            static typeof(this) perspective(MT width, MT height, MT fov, MT near, MT far) {
                typeof(this) ret;

                MT aspect = width / height;
                MT angle = radians(0.5 * fov);

                MT yScale = 1.0 / tan(angle);
                MT xScale = yScale / aspect;
                MT zScale = far / (far - near);
                
                ret.matrix[0][0] = xScale;
                ret.matrix[1][1] = yScale;
                ret.matrix[2][2] = -(far+near) * zScale;
                ret.matrix[2][3] = -(2*far*near) * zScale;
                ret.matrix[3][2] = -1.0;

                return ret;
            }

            /// Returns a perspective matrix (4x4 and floating-point matrices only).
            static typeof(this) perspective01(MT width, MT height, MT fov, MT near, MT far) {
                typeof(this) ret;

                MT aspect = width / height;
                MT angle = radians(0.5 * fov);

                MT yScale = 1.0 / tan(angle);
                MT xScale = yScale / aspect;
                MT zScale = far / (far - near);
                
                ret.matrix[0][0] = xScale;
                ret.matrix[1][1] = -yScale;
                ret.matrix[2][2] = -zScale;
                ret.matrix[2][3] = -near * zScale;
                ret.matrix[3][2] = -1.0;

                return ret;
            }

            // (2) and (3) say this one is correct
            /// Returns an orthographic matrix (4x4 and floating-point matrices only).
            static typeof(this) orthographic(MT left, MT right, MT bottom, MT top, MT near, MT far) {
                typeof(this) ret;

                ret.matrix[0][0] = 2.0 / (right-left);
                ret.matrix[0][3] = -(right+left)/(right-left);
                ret.matrix[1][1] = 2.0 / (top-bottom);
                ret.matrix[1][3] = -(top+bottom)/(top-bottom);
                ret.matrix[2][2] = -2.0 / (far - near);
                ret.matrix[2][3] = -(far+near)/(far-near);
                ret.matrix[3][3] = 1;

                return ret;
            }


            /// Returns an orthographic matrix (4x4 and floating-point matrices only).
            /// This matrix is made for Metal's NDC.
            static typeof(this) orthographic01(MT left, MT right, MT bottom, MT top, MT near, MT far) {
                typeof(this) ret;

                MT sLength = 1.0 / (right - left);
                MT sHeight = 1.0 / (top   - bottom);
                MT sDepth  = 1.0 / (far   - near);
                
                ret.matrix[0][0] = 2.0 * sLength;
                ret.matrix[1][1] = 2.0 * sHeight;
                ret.matrix[2][2] = -sDepth;
                ret.matrix[2][3] = -near * sDepth;
                ret.matrix[3][3] = 1;
                return ret;
            }

            /// Returns a look at matrix (4x4 and floating-point matrices only).
            static typeof(this) lookAt(VectorImpl!(T, 3) eye, VectorImpl!(T, 3) target, VectorImpl!(T, 3) up) {
                alias vec3MT = VectorImpl!(T, 3);
                vec3MT look_dir = (target - eye).normalized;
                vec3MT up_dir = up.normalized;

                vec3MT right_dir = look_dir.cross(up_dir).normalized;
                vec3MT perp_up_dir = right_dir.cross(look_dir);

                typeof(this) ret = typeof(this).identity;
                ret.matrix[0][0..3] = right_dir.data[];
                ret.matrix[1][0..3] = perp_up_dir.data[];
                ret.matrix[2][0..3] = (-look_dir).data[];

                ret.matrix[0][3] = -eye.dot(right_dir);
                ret.matrix[1][3] = -eye.dot(perp_up_dir);
                ret.matrix[2][3] = eye.dot(look_dir);

                return ret;
            }
        }
    }



    //
    //          PROPERTIES
    //
    static if (rows == columns) {

        /**
            The translation portion of this matrix.
        */
        @property typeof(this) translation() {
            typeof(this) result = typeof(this).identity;
            static foreach(r; 0..rows-1)
                result.matrix[r][rows-1] = this.matrix[r][rows-1];
            return result;
        }

        /**
            The scale portion of this matrix.
        */
        @property typeof(this) scale() {
            typeof(this) result;
            static foreach(i; 0..min(rows, columns)-1)
                result.matrix[i][i] = this.matrix[i][i];
            return result;
        }

        static if (rows >= 3) {

            /**
                The rotation portion of the matrix.
            */
            @property MatrixImpl!(T, 3, 3) rotation() {
                MatrixImpl!(T, 3, 3) result;
                static foreach(r; 0..3) {
                    result.matrix[r][0..3] = this.matrix[r][0..3];
                }
                return result;
            }
        }
    }

    /**
        The inverse of this matrix.
    */
    @property typeof(this) inverse() {
        return this * -1;
    }

    /**
        The transposed equivalent of this matrix.
    */
    @property MatrixImpl!(T, columns, rows) transposed() {
        MatrixImpl!(T, columns, rows) result;
        static foreach(r; 0..rows) {
            static foreach(c; 0..columns) {
                result.matrix[c][r] = this.matrix[r][c];
            } 
        }
        return result;
    }
    

    //
    //          CTORS
    //

    /**
        Constructs a new matrix indentical to the given matrix.

        Params:
            rhs = The matrix to construct this one from.
    */
    this(Y)(inout(Y) rhs)
    if (isSizeCompatibleMatrices!(typeof(this), Y)) {
        static foreach(i; 0..data.length)
            this.data[i] = rhs.data[i];
    }

    /**
        Creates a new matrix from the given scalar value.

        All components will be set to said value.

        Params:
            value = The scalar value to assign.
    */
    this(Y)(Y value) 
    if (__traits(isScalar, Y)) {
        static foreach(i; 0..data.length) {
            this.data[i] = cast(T)value;
        }
    }

    /**
        Creates a new matrix from the given scalar value.

        All components will be set to said value.

        Params:
            value = The scalar value to assign.
    */
    this(Y)(Y[c_*r_] value) 
    if (__traits(isScalar, Y)) {
        static foreach(i; 0..data.length) {
            this.data[i] = cast(T)value[i];
        }
    }


    

    //
    //          FUNCTIONS
    //






    //
    //          OP-INDEX
    //

    /**
        Allows indexing the matrix.

        Params:
            row =       The row to index
            column =    The column to index.
    
        Returns:
            The value at the given index, as a reference.
    */
    ref T opIndex(int column, int row) @safe {
        return matrix[column][row];
    }



    //
    //          OP-BINARY
    //

    /**
        Implements binary operations for the matrix type.

        Params:
            rhs = The right hand operand of the binary operation.

        Returns:
            The result of the binary operation.
    */
    auto opBinary(string op, Y)(inout(Y) rhs)
    if (isSizeCompatibleMatrices!(Y, typeof(this)) && op != "~") {
        Unqual!(typeof(this)) result;
        result.data = 0;

        static foreach(r; 0..rows) {
            static foreach(c; 0..Y.columns) {
                static foreach(c2; 0..columns) {
                    result.matrix[r][c] += mixin("this.matrix[r][c2] ", op, " cast(T)rhs.matrix[c2][c]");
                }
            }
        }
        return result;
    }

    /// ditto
    VectorImpl!(T, rows) opBinary(string op, Y)(inout(Y) rhs)
    if (isVector!Y && op != "~") {
        VectorImpl!(T, rows) result;
        result.data = 0;

        // Make a extended vector, if need be.
        static if (Y.dimensions != columns) {
            VectorImpl!(T, columns) in_;

            // Make it a compatible rank-dimensional vector.
            static if (Y.dimensions < columns)
                in_.data[$-1] = 1;

            in_.data[0..min(columns, Y.dimensions)] = lhs.data[0..min(columns, Y.dimensions)];
        } else {
            alias in_ = rhs;
        }

        static foreach(c; 0..columns) {
            static foreach(r; 0..rows) {
                result.data[r] += mixin("this.matrix[r][c] ", op, " cast(T)in_.data[c]");
            }
        }
        return result;
    }

    /// ditto
    auto opBinary(string op, Y)(inout(Y) rhs)
    if (__traits(isScalar, Y) && op != "~") {
        Unqual!(typeof(this)) result;
        static foreach(i; 0..data.length) {
            result.data[i] = mixin("this.data[i] ", op, " cast(T)rhs");
        }
        return result;
    }



    //
    //          OP-BINARY RIGHT
    //

    /**
        Implements left-handed binary operations for the vector type.

        Params:
            lhs = The left hand operand of the binary operation.
        
        Returns:
            The result of the binary operation.
    */
    auto opBinaryRight(string op, Y)(inout(Y) lhs)
    if (__traits(isScalar, Y) && op != "~") {
        Unqual!(typeof(this)) result;
        static foreach(i; 0..data.length) {
            result.data[i] = mixin("cast(T)lhs ", op, " this.data[i]");
        }
        return result;
    }

    /// ditto
    VectorImpl!(T, rows) opBinaryRight(string op, Y)(inout(Y) lhs)
    if (isVector!Y && op != "~") {
        VectorImpl!(T, rows) result;

        // Make a extended vector, if need be.
        static if (Y.dimensions != columns) {
            VectorImpl!(T, columns) in_;

            // Make it a compatible rank-dimensional vector.
            static if (Y.dimensions < columns)
                in_.data[$-1] = 1;
            in_.data[0..min(columns, Y.dimensions)] = lhs.data[0..min(columns, Y.dimensions)];
        } else {
            alias in_ = lhs;
        }

        static foreach(c; 0..columns) {
            static foreach(r; 0..rows) {
                result.data[r] += mixin("cast(T)in_.data[c] ", op, " this.matrix[r][c]");
            }
        }
        return result;
    }

}




//
//              TYPE DEFINITIONS
//

alias mat2 =    MatrixImpl!(float, 2, 2);
alias mat2x4 =  MatrixImpl!(float, 2, 4);
alias mat2x3 =  MatrixImpl!(float, 2, 3);
alias mat3 =    MatrixImpl!(float, 3, 3);
alias mat3x2 =  MatrixImpl!(float, 3, 2);
alias mat3x4 =  MatrixImpl!(float, 3, 4);
alias mat4 =    MatrixImpl!(float, 4, 4);
alias mat4x2 =  MatrixImpl!(float, 4, 2);
alias mat4x3 =  MatrixImpl!(float, 4, 3);



//
//          UNIT TESTS
//
private enum _TEST_RUNS = 100;
private enum _TEST_MIN = -100;
private enum _TEST_MAX = 100;

@("translation")
unittest {
    import std.random : uniform;
    import std.stdio : writeln;
    foreach(i; 0.._TEST_RUNS) {
        vec4 t_offset = vec4(uniform(_TEST_MIN, _TEST_MAX), uniform(_TEST_MIN, _TEST_MAX), uniform(_TEST_MIN, _TEST_MAX), 1);
        static foreach(dim; 2..4) {
            {
                alias mt = MatrixImpl!(float, dim+1, dim+1);
                alias vt = VectorImpl!(float, dim);
                assert((vt.zero * mt.translation(t_offset)).data[0..dim] == t_offset.data[0..dim]);
            }
        }
    }
}

@("scaling")
unittest {
    import std.random : uniform;
    import std.stdio : writeln;
    foreach(i; 0.._TEST_RUNS) {
        vec4 t_offset = vec4(uniform(_TEST_MIN, _TEST_MAX), uniform(_TEST_MIN, _TEST_MAX), uniform(_TEST_MIN, _TEST_MAX), 1);
        static foreach(dim; 2..4) {
            {
                alias mt = MatrixImpl!(float, dim+1, dim+1);
                alias vt = VectorImpl!(float, dim);
                assert((vt.one * mt.scaling(t_offset)).data[0..dim] == t_offset.data[0..dim]);
            }
        }
    }
}

@("identity")
unittest {
    assert(mat2.identity.data == [
            1.0, 0.0, 
            0.0, 1.0
    ]);
    assert(mat3.identity.data == [
            1.0, 0.0, 0.0, 
            0.0, 1.0, 0.0, 
            0.0, 0.0, 1.0
    ]);
    assert(mat4.identity.data == [
            1.0, 0.0, 0.0, 0.0, 
            0.0, 1.0, 0.0, 0.0, 
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
    ]);
}