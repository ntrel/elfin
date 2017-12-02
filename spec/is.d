is(TypeTest, TemplateParameterList)

// In static if tests, this form exposes optional Declarations and/or
// Alias to the `if` branch.
// TemplateParameterList declarations are no longer exposed
is(Declarations; TypeTest, TemplateParameterList)
// Note: we can avoid D ambiguity on exposing TPL by requiring a
// semi-colon for is(; Test, TPL) when used in static if.

// Alias only allowed when no type operator ==,:
is(Declarations; Alias = Type, TemplateParameterList)

// Code below assumes T is in scope

// escaping declarations come first; only allowed with static if:
static if (is(B; T == B*))
	return B.sizeof;
// is T a template instance?
static if (is(alias Tem; T == Tem!Args, Args))
	alias template = Tem;

// here decls must go in template param list, as `is` can't introduce B to scope
enum e = is(T == B*, B);

// Alias Type form
static if (is(A = T!U, U))
	A() a;

// enhancement: declare V and alias AA if Foo!T compiles and V[string] is a type
static if (is(V = Foo!T; AA = V[string]))
	return AA {"k" : new V};

// could have equivalent to `is(T B == enum)`, when B doesn't appear on RHS
// this is not intuitive what B is
static if (is(B; T == enum));
	B b = T.max;
// better: T identifier == keyword special forms become __traits instead
static if (is(T == enum))
	alias B = __traits(baseType, T);
