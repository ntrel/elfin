// Note: all parts but Type are optional
// Identifier only allowed within a `static if` test

// existing, superceded
is ( Type Identifier : TypeSpecialization , TemplateParameterList )
is ( Type Identifier == TypeSpecialization , TemplateParameterList )

// new
// separate Declarations for current scope, any TemplateParameterList decls not exposed
is(Identifier = TypeTest, Declarations; TemplateParameterList)
TypeTest:
	Type : Type
	Type == Type

// Code below assumes T is in scope

// B introduced to scope
static if (is(T == B*, B))
	return B.sizeof;
// is T a template instance?
// Tem introduced, Args not
static if (is(T == Tem!Args, alias Tem; Args))
	alias __self = Tem;
// equivalent, not in `static if`
enum e = is(T == B*; B);
enum e = is(T == B*, B); // allowed for backward compat

// Identifier form
static if (is(A = T!U; U))
	A() a;

// enhancement: multiple tests
is(TypeTests, Declarations; TemplateParameterList)
TypeTests:
	Identifier = TypeTest, TypeTests

// declare V and AA if Foo!T and V[string] are valid types
static if (is(V = Foo!T, AA = V[string]))
	return AA {"k" : new V};

// existing, kept - no Identifier
is ( Type == TypeSpecialization )
bool b = is(T == class);

// we could have equivalent to `is(T B == enum)`
TypeTest:
	Type == TypeSpecialization
// not intuitive what B is
static if (is(B = T == enum));
	B b = T.max; // B is enum base type

// better: T identifier == keyword special forms become __traits instead
static if (is(T == enum))
	__traits(baseType, T) b = T.max;
