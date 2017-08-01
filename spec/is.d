is(Declarations; TypeTest, TemplateParameterList)

// declarations come first when is used in static if:
static if (is(B; T == B*));
static if (is(alias Tem, Args; T == Tem!Args));
// here decls must go in template param list, as B not introduced to scope
enum e = is(T == B*, B);

// A is an alias of T as it doesn't appear in TPL
static if (is(A; T));
// Alt syntax, doesn't work like is(T identifier == keyword) forms, but see traits below
static if (is(A = T; A));
// A is T, not enum base type
static if (is(A = T; A == enum));
static if (is(V = Foo!(int[2]), AA = V[char[]]; AA)) alias template = AA;

// equivalent to `is(T B == enum)` if B doesn't appear on RHS
static if (is(B; T == enum));
// probably T identifier == keyword special forms should be __traits instead
static if (is(E = T; E == enum)) alias B = __traits(baseType, E);
