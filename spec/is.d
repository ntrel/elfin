// Note: all parts but Type are optional
// Identifier only allowed within a `static if` test

// existing, superceded
is ( Type Identifier : TypeSpecialization , TemplateParameterList )
is ( Type Identifier == TypeSpecialization , TemplateParameterList )

// new
// 2 separate TPLs - current scope declarations, then any TemplateParameterList decls not exposed
is(Identifier = TypeTest, TemplateParameterList; TemplateParameterList)
TypeTest:
	Type : Type
	Type == Type

// Code below assumes T is in scope

## Declarations

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

## Identifier form

static if (is(A = T!int))
	A() a;

// Identifier = TypeTest always makes Identifier an alias for Type:
static if (is(T U : U*)) // existing, U != T
static if (is(U = T : U*)) // error, U cannot appear after `=`
static if (is(T : U*, U)) // use TPL, not Identifer

## Enhancement: multiple tests

is(TypeTests, TemplateParameterList; TemplateParameterList)
TypeTests:
	Identifier = TypeTest, TypeTests

// declare V and AA if Foo!T and V[string] are valid types
static if (is(V = Foo!T, AA = V[string]))
	return AA {"k" : new V};

## Type == Keyword

// existing, kept as there's no Identifier
is ( Type == TypeSpecialization )
enum b = is(T == class);

// we could have equivalent to `is(T B == enum)`
TypeTest:
	Type == TypeSpecialization
// not intuitive what B is
static if (is(B = T == enum));
	B b = T.max; // B is enum base type

// better: T identifier == keyword special forms become __traits instead
static if (is(T == enum))
	__traits(baseType, T) b = T.max;
