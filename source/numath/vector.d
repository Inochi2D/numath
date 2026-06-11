/**
    NuMath Linear Algebra

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.vector;
import numem.core.traits;
import numem.core.meta;
import numath.limits;
import numath.math;

/**
	Gets whether the given type is a valid mathematic vector.	
*/
enum isVector(T) = is(T == VectorImpl!U, U...);

/**
	Gets whether the 2 given vector types are of the same size.
*/
enum isSizeCompatibleVectors(VT1, VT2) = (isVector!VT1 && isVector!VT2) && VT1.dimensions == VT2.dimensions;

/**
	A mathematical vector.
*/
struct VectorImpl(T, int dims)
if (__traits(isScalar, T) && dims >= 2 && dims <= NUMATH_VEC_MAX_DIMS) {
@nogc nothrow pure:
public:
	union {
		/**
			Vector data stored linearly.
		*/
		T[dims] data = 0;

		struct {
			union {
				
				/**
					X component of the vector.
				*/
				T x;
				
				/**
					S component of the UV coordinate vector.
				*/
				T s;
				
				/**
					U component of the UV coordinate vector.
				*/
				T u;
				
				/**
					Red channel of the color vector
				*/
				T r;
			}
			union {
				
				/**
					Y component of the vector.
				*/
				T y;
				
				/**
					T component of the UV coordinate vector.
				*/
				T t;
				
				/**
					V component of the UV coordinate vector.
				*/
				T v;
				
				/**
					Green channel of the color vector
				*/
				T g;
			}
			static if (dims >= 3)
			union {
				
				/**
					Z component of the vector.
				*/
				T z;
				
				/**
					P component of the UV coordinate vector.
				*/
				T p;
				
				/**
					Blue channel of the color vector
				*/
				T b;
			}
			 
			static if (dims >= 4)
			union {
				
				/**
					W component of the vector.
				*/
				T w;
				
				/**
					Q component of the UV coordinate vector.
				*/
				T q;
				
				/**
					Alpha channel of the color vector
				*/
				T a;
			}
		}
	}

	/**
		The type of the vector storage.
	*/
	alias VT = T;

	/**
		The dimensionality of the vector.
	*/
	enum dimensions = dims;



	//
	//			PROPERTIES
	//

	/**
		Pointer to the start of the vector's data.
	*/
	@property const(T)* ptr() const => cast(const(T)*)data.ptr;

	/**
		The length of the vector, squared.
	*/
	@property T lengthSquared() const {
		T tmp = 0;
		static foreach(i; 0..dims)
			tmp += data[i]^^2;
		return tmp;
	}

	/**
		The length of the vector.
	*/
	@property real length() const => sqrt(cast(real)lengthSquared);

	/**
		The normalized version of this vector.
	*/
	@property typeof(this) normalized() const {
		real len = length;
		Unqual!(typeof(this)) result;
		static foreach(i; 0..dims)
			result.data[i] = cast(T)(data[i] / len);
		return result;
	}

	/**
		Whether the vector only contains finite values.
	*/
	@property bool isFinite() const {
		static if (__traits(isFloating, T)) {
			static foreach(i; 0..dims)
				if (!data[i].isFinite)
					return false;
		}
		return true;
	}


	

	//
	//			CTORS
	//

	/**
		Creates a new vector from another vector. 

		Params:
			rhs = The other vector to construct this vector from.
	*/
	this(Y)(inout(Y) rhs)
	if (isVector!Y) {
		static foreach(i; 0..nu_min(dims, Y.dimensions)) {
			this.data[i] = cast(T)rhs.data[i];
		}
	}

	/**
		Creates a new vector from the given scalar values.

		Params:
			args = The scalar values to assign.
	*/
	this(Args...)(Args args) 
	if (Args.length == dims && allSatisfy!(isScalar, Args)) {
		static foreach(i; 0..nu_min(dims, Args.length)) {
			this.data[i] = cast(T)args[i];
		}
	}

	/**
		Creates a new vector from the given scalar value.

		All components will be set to said value.

		Params:
			args = The scalar values to assign.
	*/
	this(Y)(Y value) 
	if (__traits(isScalar, Y)) {
		static foreach(i; 0..dims) {
			this.data[i] = cast(T)value;
		}
	}


	

	//
	//			FUNCTIONS
	//

	/**
		Gets the dot product between this and another vector of
		equal size.

		Params:
			rhs = The vector to get the dot product against.

		Returns:
			The dot product of this and the other vector.
	*/
	T dot(Y)(inout(Y) rhs) 
	if (isVector!Y && Y.dimensions == this.dims) {
		T tmp = 0;
		static foreach(i; 0..dims)
			tmp += data[i] * cast(T)rhs.data[i];

		return tmp;
	}

	/**
		Gets the cross product between this vector and another
		3-dimensional vector.

		Params:
			rhs = The right hand side vector.

		Returns:
			The cross-product of the 2 vectors.
	*/
	auto cross(Y)(inout(Y) rhs)
	if (isSizeCompatibleVectors!(typeof(this), Y) && dims == 3) {
		return typeof(this)(
			(this.data[1]*cast(T)other.data[2]) - (this.data[2]-cast(T)other.data[1]),
			(this.data[2]*cast(T)other.data[0]) - (this.data[0]-cast(T)other.data[2]),
			(this.data[0]*cast(T)other.data[1]) - (this.data[1]-cast(T)other.data[0]),
		);
	}

	/**
		Gets the distance between this vector and the other vector.

		Params:
			rhs = The right hand side vector.

		Returns:
			The distance between the 2 vectors.
	*/
	T distance(Y)(inout(Y) rhs)
	if (isVector!Y) {
		return (this - rhs).length;
	}

	/**
		Reflects the vector against the given surface normal.

		Params:
			norm = The surface normal.

		Returns:
			The derived reflection vector.

		See_Also:
			$(LINK2 https://registry.khronos.org/OpenGL-Refpages/gl4/html/reflect.xhtml, reflect - GLSL Documentation)
	*/
	auto reflect(Y)(inout(Y) norm) 
	if(isSizeCompatibleVectors!(typeof(this), Y)) {
		return (2 * (this * norm) * norm) - this;
	}

	/**
		Calculates the refraction direction for the given incident
		vector.

		The normal and input vector should be normalized to achieve
		the desired result.

		Params:
			incident = 	The incident vector.
			eta = 		The ratio of indices of refraction.

		Returns:
			The derived refraction vector.

		See_Also:
			$(LINK2 https://registry.khronos.org/OpenGL-Refpages/gl4/html/refract.xhtml, refract - GLSL Documentation)
	*/
	auto refract(Y)(inout(Y) incident, real eta)
	if(isSizeCompatibleVectors!(typeof(this), Y)) {
		real k = 1.0 - eta * eta * (1.0 - this.dot(incident) * this.dot(incident));
		if (k < 0.0)
			return typeof(this)(0);
		else
			return eta * incident - (eta * this.dot(incident) + sqrt(k)) * this;
	}



	//
	//			OP-BINARY
	//

	/**
		Implements binary operations for the vector type.

		Params:
			rhs = The right hand operand of the binary operation.
	*/
	auto opBinary(string op, Y)(inout(Y) rhs)
	if (isVector!Y && op != "~") {
		Unqual!(typeof(this)) result;
		static foreach(i; 0..nu_min(dims, Y.dimensions)) {
			result.data[i] = mixin("this.data[i] ", op, " cast(T)rhs.data[i]");
		}
		return result;
	}

	/// ditto
	auto opBinary(string op, Y)(inout(Y) rhs)
	if (__traits(isScalar, Y) && op != "~") {
		Unqual!(typeof(this)) result;
		static foreach(i; 0..dims) {
			result.data[i] = mixin("this.data[i] ", op, " cast(T)rhs");
		}
		return result;
	}

	/// ditto
	auto opBinaryRight(string op, Y)(inout(Y) rhs)
	if (__traits(isScalar, Y) && op != "~") {
		Unqual!(typeof(this)) result;
		static foreach(i; 0..dims) {
			result.data[i] = mixin("cast(T)rhs ", op, " this.data[i]");
		}
		return result;
	}




	//
	//			OP-OP-ASSIGN
	//

	/**
		Implements assignment operations for the vector type.

		Params:
			rhs = The right hand operand of the binary operation.
	*/
	void opOpAssign(string op, Y)(inout(Y) rhs)
	if (isVector!Y && op != "~") {
		static foreach(i; 0..nu_min(dims, Y.dimensions)) {
			mixin("this.data[i] ", op, "= cast(T)rhs.data[i]");
		}
	}

	/// ditto
	void opOpAssign(string op, Y)(inout(Y) rhs)
	if (__traits(isScalar, Y) && op != "~") {
		static foreach(i; 0..dims) {
			mixin("this.data[i] ", op, "= cast(T)rhs");
		}
	}




	//
	//			OP-CMP
	//

	/**
	
	*/
	int opCmp(Y)(ref inout(Y) rhs) const 
	if (isVector!Y && Y.dims == this.dims) {
		static foreach(i; 0..nu_min(dims, Y.dims)) {
			if (this.data[i] < rhs.data[i])
				return -1;
			else if(this.data[i] > rhs.data[i])
				return 1;
		}
	
		return 0;
	}




	//
	//			OP-EQUALS
	//
	bool opEquals(Y)(inout(Y) rhs) const
	if (isSizeCompatibleVectors!(typeof(this), Y)) {
		return data == rhs.data;
	}




	//
	//			SWIZZLING
	//

	/**
		Implements swizzling.
	*/
	VectorImpl!(T, s.length) opDispatch(string s)() const
	if (s.length > 1 && s.length <= NUMATH_VEC_MAX_DIMS) {
		VectorImpl!(T, s.length) result;
		import nulib.text.ascii : toLower;
		static foreach(i; 0..s.length) {
			result.data[i] = mixin("this.", s[i].toLower());
		}
		return result;
	}
}




//
//				TYPE DEFINITIONS
//

/**
	2-dimensional single-precision floating point vector.
*/
alias vec2 = VectorImpl!(float, 2);

/**
	3-dimensional single-precision floating point vector.
*/
alias vec3 = VectorImpl!(float, 3);

/**
	4-dimensional single-precision floating point vector.
*/
alias vec4 = VectorImpl!(float, 4);

/**
	2-dimensional double-precision floating point vector.	
*/
alias dvec2 = VectorImpl!(double, 2);

/**
	3-dimensional double-precision floating point vector.	
*/
alias dvec3 = VectorImpl!(double, 3);

/**
	4-dimensional double-precision floating point vector.	
*/
alias dvec4 = VectorImpl!(double, 4);

/**
	2-dimensional unsigned integer vector.
*/
alias ivec2 = VectorImpl!(int, 2);

/**
	3-dimensional unsigned integer vector.
*/
alias ivec3 = VectorImpl!(int, 3);

/**
	4-dimensional unsigned integer vector.
*/
alias ivec4 = VectorImpl!(int, 4);

/**
	2-dimensional signed integer vector.
*/
alias uvec2 = VectorImpl!(uint, 2);

/**
	3-dimensional signed integer vector.
*/
alias uvec3 = VectorImpl!(uint, 3);

/**
	4-dimensional signed integer vector.
*/
alias uvec4 = VectorImpl!(uint, 4);




//
//			UNIT TESTS
//
private enum _TEST_RUNS = 100;

private template __arith_test(T, string op) {
	void __arith_test() {
		import std.random;

		static if (__traits(isFloating, T))
			alias rng = () => cast(T)((uniform01()-0.5)*1000.0);
		else
			alias rng = () => cast(T)uniform(T.min, T.max);

		static foreach(dim; 2..4) {
			foreach(i; 0.._TEST_RUNS) {
				VectorImpl!(T, dim) a;
				VectorImpl!(T, dim) b;
				T[dim] expected;

				static foreach(x; 0..dim) {
					a.data[x] = rng();
					b.data[x] = rng();
					expected[x] = mixin("a.data[x]", op, "b.data[x]");
				}


				assert(mixin("a", op, "b").data == expected);
			}
		}
	}
}

@("+")
unittest {
	__arith_test!(float, 	"+")();
	__arith_test!(double, 	"+")();
	__arith_test!(int, 		"+")();
}

@("-")
unittest {
	__arith_test!(float, 	"-")();
	__arith_test!(double, 	"-")();
	__arith_test!(int, 		"-")();
}

@("*")
unittest {
	__arith_test!(float, 	"*")();
	__arith_test!(double, 	"*")();
	__arith_test!(int, 		"*")();
}

@("/")
unittest {
	__arith_test!(float, 	"/")();
	__arith_test!(double, 	"/")();
	__arith_test!(int, 		"/")();
}

@("swizzling")
unittest {
	vec4 a = ivec4(0, 1, 2, 3);
	assert(a.wzyx == ivec4(3, 2, 1, 0));
	assert(a.uvuv == a.rgrg);
}