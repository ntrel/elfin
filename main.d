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
    comment,
    identifier,
    //~ keyword,
    operator,
    string,
}

final class Token
{
    TokenType type;
    OpType op;
    string src;
    string after;
}

import std.stdio;
import std.algorithm;
import std.ascii;
import std.range;

OpType[string] ops;

size_t maxOpLen;

auto takeFront(R)(R r)
{
    auto v = r.front;
    r.popFront;
    return v;
}

bool isOpChar(dchar c)
{
    return c.isPunctuation && c != '_' && c != '@';
}

Token readToken(ref string text)
{
    with (TokenType) {
    auto tok = new Token;
    auto start = text;
    
    //~ if (start.empty)
    auto c = text.takeFront;
    
    if (c.isOpChar)
    {
        tok.type = operator;
        auto len = 1;
        if (text[0].isOpChar)
        {
            len = 2;
            text.popFront;
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
    return tok;
}}

void main(string[] args)
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
    import std.file;
    auto text = args[1].readText;
    Token tok;
    tok = readToken(text);
    
    version (None)
    with (OpType)
    {
        if (tok.match(identifier, colon, braceL, tok))
        {
            if (tok.peek.type != braceR)
                warn("Note: Labelled blocks are not scoped (move label inside block)");
        }
        Token tok2;
        // version(!Foo) -> version(Foo){} else
        if (tok.match("version", bracketL, not, tok, identifier, bracketR, tok2))
        {
            tok.src = "";
            tok2.after = "{} else";
            tok = tok2;
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

