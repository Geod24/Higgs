/*****************************************************************************
*
*                      Higgs JavaScript Virtual Machine
*
*  This file is part of the Higgs project. The project is distributed at:
*  https://github.com/maximecb/Higgs
*
*  Copyright (c) 2011-2013, Maxime Chevalier-Boisvert. All rights reserved.
*
*  This software is licensed under the following license (Modified BSD
*  License):
*
*  Redistribution and use in source and binary forms, with or without
*  modification, are permitted provided that the following conditions are
*  met:
*   1. Redistributions of source code must retain the above copyright
*      notice, this list of conditions and the following disclaimer.
*   2. Redistributions in binary form must reproduce the above copyright
*      notice, this list of conditions and the following disclaimer in the
*      documentation and/or other materials provided with the distribution.
*   3. The name of the author may not be used to endorse or promote
*      products derived from this software without specific prior written
*      permission.
*
*  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
*  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
*  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
*  NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
*  NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
*  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*****************************************************************************/

import std.stdio;
import std.getopt;

struct Options
{
    /// String of code to execute
    string execString = null;

    /// Force a repl, even after loading files or executing a string
    bool repl = false;

    /// Gather and report various statistics about program execution
    bool stats = false;

    /// Gather performance statistics
    bool perf_stats = false;

    /// Set stdout to be unbuffered
    bool unbuffered = false;

    /* VM options */

    /// Disable loading of the runtime library
    bool noruntime = false;

    /// Disable loading of the standard library
    bool nostdlib = false;

    /* JIT options */

    /// Enable IR-level type propagation analysis
    bool jit_typeprop = false;

    /// Enable eager generation of block versions
    bool jit_eager = false;

    /// Maximum number of specialized versions to compile per basic block
    uint jit_maxvers = 20;

    /// Disable peephole optimizations
    bool jit_nopeephole = false;

    /// Disable inlining in the JIT
    bool jit_noinline = false;

    /// Dump information about JIT compilation
    bool jit_dumpinfo = false;

    /// Dump the IR of functions compiled by the JIT
    bool jit_dumpir = false;

    /// Store disassembly for the generated machine code
    bool jit_genasm = false;

    /// Dump disassembly for all the generated machine code
    bool jit_dumpasm = false;

    /// Log a trace of the instructions executed
    bool jit_trace_instrs = false;
}

/// Global options structure
Options opts;

/**
Parse the command-line arguments
*/
void parseCmdArgs(ref string[] args)
{
    getopt(
        args,
        config.stopOnFirstNonOption,
        config.passThrough,

        "e"                 , &opts.execString,
        "unbuffered"        , &opts.unbuffered,
        "repl"              , &opts.repl,
        "stats"             , &opts.stats,
        "perf_stats"        , &opts.perf_stats,

        "noruntime"         , &opts.noruntime,
        "nostdlib"          , &opts.nostdlib,

        "jit_typeprop"      , &opts.jit_typeprop,
        "jit_eager"         , &opts.jit_eager,
        "jit_maxvers"       , &opts.jit_maxvers,
        "jit_nopeephole"    , &opts.jit_nopeephole,
        "jit_noinline"      , &opts.jit_noinline,
        "jit_dumpinfo"      , &opts.jit_dumpinfo,
        "jit_dumpir"        , &opts.jit_dumpir,
        "jit_genasm"        , &opts.jit_genasm,
        "jit_dumpasm"       , &opts.jit_dumpasm,
        "jit_trace_instrs"  , &opts.jit_trace_instrs
    );

    // If we don't load the runtime, we can't load the standard library
    if (opts.noruntime)
        opts.nostdlib = true;

    // If dumping the ASM, we must first generate the ASM
    if (opts.jit_dumpasm)
        opts.jit_genasm = true;
}

