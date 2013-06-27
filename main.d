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


enum TokenType
{
    braceL,
    braceR,
    bracketL,
    bracketR,
    colon,
    divide,
    divideEquals,
    equals,
    goesTo,
    semiColon,
    
    comment,
    identifier,
    keyword,
    string,
}

struct Token
{
    TokenType type;
}

import std.stdio;

void main(string[] args)
{
    with (TokenType)
    auto tokens = [
        "{":braceL,
        "}":braceR,
        "(":bracketL,
        ")":bracketR,
        ":":colon,
        "/":divide,
        "/=":divideEquals,
        "=":equals,
        "=>":goesTo,
        ";":semiColon,
    ];
    import std.file;
    auto text = args[1].readText;
    Token tok;
    void read(ref Token tok, ref string text)
    {
        
    }
    tok.read(text);
    
    version (None)
    with (TokenType)
    {
        if (tok.match(identifier, colon, braceL))
        {
            if (tok.peek(3).type != braceR)
                warn("Label before block not recommended - move label inside block");
        }
        // typeof(1 / 2) == real;
        if (tok.type == divide)
            tok.after ~= " cast(real)";
    }
}

