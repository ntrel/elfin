// Written in the D programming language.
/*
 * main.d
 * 
 * Copyright 2013 Nick Treleaven <nick dot treleaven at btinternet com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


enum OpType
{
    braceL,
    braceR,
    bracketL,
    bracketR,
    colon,
    divide,
    divideEquals,
    //~ equals,
    goesTo,
    not,
    semiColon,
}
    
enum TokenType
{
    identifier,
    //~ keyword,
    operator,
    string,
}

struct Token
{
    TokenType type;
    OpType op;
    string header;
    string src;
    string after;
    size_t index;

    Token next()
    {
        return tokens[index + 1];
    }

    bool hasNext()
    {
        return index + 1 < tokens.length;
    }
}

import std.algorithm;
import std.ascii;
import std.range;
import std.stdio;
import std.string;
import std.exception;

Token[] tokens;
size_t tokenIndex;

OpType[string] ops;
size_t maxOpLen;

size_t line = 1;

void error(string msg)
{
    import std.c.stdlib;
    stderr.writefln("(%s): Error: %s", line, msg);
    exit(1);
}

alias drop = popFront;

// Note: some ranges don't have persistent front e.g. ByLine
auto takeFront(T)(T[] r)
{
    auto v = r.front;
    r.drop;
    return v;
}

string readHeader(ref string text)
{
    auto start = text;
    while (text[0].isWhite)
    {
        do
        {
            if (text[0] == '\r')
            {
                if (text[1] == '\n')
                    text.drop;
            }
            else if (text[0] != '\n')
                break;
            line++;
        } while (0);
        text.drop;
    }
    start.length -= text.length;
    return start;
}

bool isOpChar(dchar c)
{
    return c.isPunctuation && c != '_' && c != '@';
}

Token readToken(ref string text)
{
    with (TokenType) {
    Token tok;
    tok.header = readHeader(text);
    
    auto start = text;
    auto c = text.takeFront;
    
    if (c.isOpChar)
    {
        tok.type = operator;
        auto len = 1;
        if (text[0].isOpChar)
        {
            len = 2;
            text.drop;
        }
        tok.src = start[0..len];
        auto ptr = tok.src in ops;
        tok.op = *ptr;
    }
    else if (c.isAlpha)
    {
        tok.type = identifier;
        auto len = 0;
        do len++; while (text.takeFront.isAlphaNum);
        tok.src = start[0..len];
    }
    else
        error(format("Unknown character '%s'", c));
    
    return tok;
}}

static this()
{
    with (OpType)
    ops = [
        "{":braceL,
        "}":braceR,
        "(":bracketL,
        ")":bracketR,
        ":":colon,
        "/":divide,
        "/=":divideEquals,
        //~ "=":equals,
        "=>":goesTo,
        "!":not,
        ";":semiColon,
    ];
    maxOpLen = ops.keys.map!(s => s.length).reduce!((a, b) => a + b);
}

void main(string[] args)
{
    import std.file;
    auto text = args[1].readText;
    enforce(!text.find('\0'), "Null bytes not allowed!");
    text ~= '\0'; // to avoid checking text.length
    
    Token tok;
    do
    {
        tok = readToken(text);
        tok.index = tokenIndex++;
        tokens ~= tok;
    } while (text[0] != '\0');
    
    tok = tokens[0];
    while (true)
    {
        parse(tok);
        if (!tok.hasNext)
            break;
        tok = tok.next;
    }
}

void parse(ref Token tok)
{
    version (None)
    with (OpType)
    {
        if (tok.match(identifier, colon, braceL, tok))
        {
            if (tok.peek.type != braceR)
                warn("Note: Labelled blocks are not scoped (move label inside block)");
        }
        Token tok2;
        // 'T& v' but not 'T &v', 'x & y'
        if (tok.header == "" && tok.match(identifier, ampersand, tok2))
        {
            Token t = tok2.next;
            // not 'T&v' but '(T&)', '[T&]' ok
            if ((t.header.length && t.header[0].isWhite) ||
                ")]".canFind(t.src[0]))
            {
                tok.before = "NonNull!(";
                tok2.src = ")";
            }
            tok = tok2;
        }
        // version(!Foo) -> static if(!Version!"Foo")
        if (tok.match("version", bracketL, not, identifier, tok2, bracketR))
        {
            tok.src = "static if";
            tok2.before = "Version!\"";
            tok2.after = "\"";
            tok = tok2.next;
        }
    }
    // incompatible
    version (E)
    with (OpType)
    {
        // typeof(1 / 2) == real;
        if (tok.type == divide)
            tok.after ~= " cast(real)";
    }
}

