

#include "lua.h"
#include "lualib.h"
#include "Luau/Common.h"
#ifdef LUAU_ORACLE_FASTPCALL_EVIDENCE
#include "lstate.h"
#include "lobject.h"
#include "Luau/BytecodeUtils.h"
#endif
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <unordered_map>
#include <vector>
#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

using Bytes = std::vector<unsigned char>;
static constexpr size_t MAX_FRAME = 16 * 1024 * 1024;
struct Budget {
    size_t live = 0;
    std::chrono::steady_clock::time_point deadline;
    Bytes events;
    unsigned event_count = 0;
    bool complete = true;
    bool oracle_error = false;
    bool timed_out = false;
    unsigned fastpcall_seen = 0;
    unsigned fastpcall_eligible = 0;
    unsigned fastpcall_eligible_lua = 0;
    unsigned fastpcall_eligible_c = 0;
    bool observe_protected = false;
    std::unordered_map<const void*, unsigned> identities;
    std::vector<int> retained;
};





static void protected_call_evidence(lua_State* state, Budget& budget)
{
#ifdef LUAU_ORACLE_FASTPCALL_EVIDENCE
    if (!budget.observe_protected) return;
    CallInfo* ci = state->ci;
    if (!ci || !ttisfunction(ci->func) || clvalue(ci->func)->isC) return;
    Closure* closure = clvalue(ci->func);
    Proto* proto = closure->l.p;
    const Instruction* after = ci->savedpc;
    const auto begin = reinterpret_cast<std::uintptr_t>(proto->code);
    const auto location = reinterpret_cast<std::uintptr_t>(after);
    const auto end = begin + std::uintptr_t(proto->sizecode) * sizeof(Instruction);
    if (!after || location < begin + 2 * sizeof(Instruction) || location > end + sizeof(Instruction)
        || (location - begin) % sizeof(Instruction) != 0) return;
    size_t position = (location - begin) / sizeof(Instruction) - 2;
    if (position >= size_t(proto->sizecode)) return;
    const Instruction* candidate = proto->code + position;
    Instruction fast = *candidate;
    if ((fast & 255) != 89) return;
    const Instruction* header = proto->code;
    while (header < candidate) header += Luau::getOpLength(LuauOpcode(*header & 255));
    if (header != candidate) return;
    budget.fastpcall_seen++;
    unsigned pfid = (fast >> 8) & 255;
    unsigned skip = fast >> 24;
    if (pfid > 1 || position + 1 + skip >= size_t(proto->sizecode)) return;
    const Instruction* target = proto->code + position + 1 + skip;
    if ((*target & 255) != 21) return;
    StkId frame = state->base + ((*target >> 8) & 255);
    int count = int((*target >> 16) & 255) - 1;
    if (count == -1) count = int(state->top - frame - 1);
    bool builtin = pfid == 0 ? state->global->builtinPcall != nullptr : state->global->builtinXpcall != nullptr;
    if (closure->env->safeenv && state->nCcalls <= state->baseCcalls && builtin
        && count >= int(pfid + 1) && ttisfunction(frame + 1)
        && (pfid == 0 || ttisfunction(frame + 2))) {
        budget.fastpcall_eligible++;
        if (clvalue(frame + 1)->isC) budget.fastpcall_eligible_c++;
        else budget.fastpcall_eligible_lua++;
    }
#else
    (void)state; (void)budget;
#endif
}

static void* allocate(void* ud, void* pointer, size_t old_size, size_t new_size)
{
    auto* budget = static_cast<Budget*>(ud);
    if (!pointer) old_size = 0;
    if (!new_size) { budget->live -= old_size; std::free(pointer); return nullptr; }
    if (new_size > 64 * 1024 * 1024 - (budget->live - old_size)) return nullptr;
    void* result = std::realloc(pointer, new_size);
    if (result) budget->live = budget->live - old_size + new_size;
    return result;
}

static bool raw(Bytes& out, const void* data, size_t length)
{
    if (length > MAX_FRAME - out.size()) return false;
    const auto* begin = static_cast<const unsigned char*>(data);
    if (length) out.insert(out.end(), begin, begin + length);
    return true;
}
static bool byte(Bytes& out, unsigned value) { unsigned char b = static_cast<unsigned char>(value); return raw(out, &b, 1); }
static bool u32(Bytes& out, unsigned value)
{
    unsigned char b[4] = {static_cast<unsigned char>(value), static_cast<unsigned char>(value >> 8), static_cast<unsigned char>(value >> 16), static_cast<unsigned char>(value >> 24)};
    return raw(out, b, 4);
}
static bool u64(Bytes& out, unsigned long long value)
{
    unsigned char b[8];
    for (unsigned i = 0; i < 8; ++i) b[i] = static_cast<unsigned char>(value >> (i * 8));
    return raw(out, b, 8);
}

static unsigned identity(lua_State* state, int index, Budget& budget)
{
    const void* pointer = lua_topointer(state, index);
    auto found = budget.identities.find(pointer);
    if (found != budget.identities.end()) return found->second;
    unsigned id = unsigned(budget.identities.size() + 1);
    budget.identities.emplace(pointer, id);

    budget.retained.push_back(lua_ref(state, index));
    return id;
}

static bool value(lua_State* state, int index, Budget& budget, Bytes& out)
{
    int type = lua_type(state, index);
    switch (type) {
    case LUA_TNIL: return byte(out, 0);
    case LUA_TBOOLEAN: return byte(out, 1) && byte(out, lua_toboolean(state, index) ? 1 : 0);
    case LUA_TNUMBER: {
        double number = lua_tonumber(state, index);
        unsigned long long bits = 0;
        static_assert(sizeof(number) == sizeof(bits), "f64 oracle requires IEEE64 Lua numbers");
        std::memcpy(&bits, &number, sizeof(bits));
        return byte(out, 2) && u64(out, bits);
    }
    case LUA_TSTRING: {
        size_t length = 0;
        const char* text = lua_tolstring(state, index, &length);
        return length <= MAX_FRAME && byte(out, 3) && u32(out, unsigned(length)) && raw(out, text, length);
    }
    case LUA_TVECTOR: {
        const float* vector = lua_tovector(state, index);
        if (!byte(out, 4) || !byte(out, LUA_VECTOR_SIZE)) return false;
        for (unsigned i = 0; i < LUA_VECTOR_SIZE; ++i) {
            unsigned bits = 0;
            std::memcpy(&bits, vector + i, 4);
            if (!u32(out, bits)) return false;
        }
        return true;
    }
    case LUA_TBUFFER: {
        size_t length = 0;
        const void* buffer = lua_tobuffer(state, index, &length);
        return length <= MAX_FRAME && byte(out, 5) && u32(out, identity(state, index, budget)) && u32(out, unsigned(length)) && raw(out, buffer, length);
    }
    default:


        budget.complete = false;
        return byte(out, 6) && byte(out, unsigned(type)) && u32(out, identity(state, index, budget));
    }
}

static bool tuple(lua_State* state, int start, unsigned count, Budget& budget, Bytes& out)
{
    if (count > 65536 || !u32(out, count)) return false;
    for (unsigned index = 0; index < count; ++index)
        if (!value(state, start + int(index), budget, out)) return false;
    return true;
}

static int effect(lua_State* state, unsigned kind)
{
    auto& budget = *static_cast<Budget*>(lua_callbacks(state)->userdata);
    Bytes event;
    if (budget.event_count >= 100000 || !byte(event, kind) || !tuple(state, 1, unsigned(lua_gettop(state)), budget, event)
        || !raw(budget.events, event.data(), event.size())) {
        budget.oracle_error = true;
        luaL_error(state, "oracle observation budget exceeded");
    }
    ++budget.event_count;




    int count = lua_gettop(state);
    for (int index = 1; index <= count; ++index) {
        size_t length = 0;
        luaL_tolstring(state, index, &length);
        lua_pop(state, 1);
    }
    return 0;
}
static int print_effect(lua_State* state) { return effect(state, 1); }
static int warn_effect(lua_State* state) { return effect(state, 2); }

static bool read_file(const std::string& path, Bytes& out)
{
    std::ifstream input(path, std::ios::binary | std::ios::ate);
    if (!input) return false;
    std::streamoff length = input.tellg();
    if (length < 0 || static_cast<unsigned long long>(length) > MAX_FRAME) return false;
    out.resize(static_cast<size_t>(length));
    input.seekg(0);
    return !length || bool(input.read(reinterpret_cast<char*>(out.data()), length));
}
struct Args {
    const Bytes& bytes;
    size_t offset = 0;
    bool take(unsigned& value) { if (offset == bytes.size()) return false; value = bytes[offset++]; return true; }
    bool word(unsigned& value) {
        if (bytes.size() - offset < 4) return false;
        value = unsigned(bytes[offset]) | unsigned(bytes[offset + 1]) << 8 | unsigned(bytes[offset + 2]) << 16 | unsigned(bytes[offset + 3]) << 24;
        offset += 4; return true;
    }
    bool number(unsigned long long& value) {
        if (bytes.size() - offset < 8) return false;
        value = 0; for (unsigned i = 0; i < 8; ++i) value |= static_cast<unsigned long long>(bytes[offset++]) << (8 * i);
        return true;
    }
};
static bool arguments(lua_State* state, const Bytes& bytes, int& count)
{
    if (bytes.size() < 9 || std::memcmp(bytes.data(), "LARG\1", 5)) return false;
    Args input{bytes, 5}; unsigned total = 0;
    if (!input.word(total) || total > 4096 || !lua_checkstack(state, int(total + 8))) return false;
    for (unsigned i = 0; i < total; ++i) {
        unsigned tag = 0;
        if (!input.take(tag)) return false;
        if (tag == 0) lua_pushnil(state);
        else if (tag == 1) { unsigned b = 0; if (!input.take(b) || b > 1) return false; lua_pushboolean(state, int(b)); }
        else if (tag == 2) { unsigned long long bits = 0; if (!input.number(bits)) return false; double n = 0; std::memcpy(&n, &bits, 8); lua_pushnumber(state, n); }
        else if (tag == 3 || tag == 5) {
            unsigned length = 0; if (!input.word(length) || length > bytes.size() - input.offset) return false;
            if (tag == 3) lua_pushlstring(state, reinterpret_cast<const char*>(bytes.data() + input.offset), length);
            else { void* b = lua_newbuffer(state, length); if (length) std::memcpy(b, bytes.data() + input.offset, length); }
            input.offset += length;
        } else if (tag == 4) {
            unsigned n = 0; if (!input.take(n) || n != LUA_VECTOR_SIZE) return false;
            float components[LUA_VECTOR_SIZE];
            for (unsigned j = 0; j < n; ++j) { unsigned bits = 0; if (!input.word(bits)) return false; std::memcpy(components + j, &bits, 4); }
#if LUA_VECTOR_SIZE == 4
            lua_pushvector(state, components[0], components[1], components[2], components[3]);
#else
            lua_pushvector(state, components[0], components[1], components[2]);
#endif
        } else return false;
    }
    count = int(total);
    return input.offset == bytes.size();
}

int main(int argc, char** argv)
{
#ifdef _WIN32
    _setmode(_fileno(stdout), _O_BINARY);
#endif
    if (argc == 2 && std::string(argv[1]) == "--protocol-version") { std::fputs("LOBS/1 LARG/1\n", stdout); return 0; }
    Luau::FValue<bool>* fastpcall = nullptr;
    for (auto* flag = Luau::FValue<bool>::list; flag; flag = flag->next)
        if (std::strcmp(flag->name, "LuauFastpcall") == 0) { fastpcall = flag; break; }
    if (argc == 2 && std::string(argv[1]) == "--runtime-flags") {
        if (fastpcall) std::printf("LuauFastpcall=%s\n", fastpcall->value ? "true" : "false");
        else std::fputs("LuauFastpcall=unavailable\n", stdout);
        return 0;
    }
    if (argc < 2) { std::fprintf(stderr, "usage: vm-runner BYTECODE [--args ARGS.bin] [--probe PROBE.bc] [--fastpcall true|false] [--repeat-entry 1..16]\n"); return 2; }
    std::string args_path, probe_path;
    bool protected_mode_requested = false;
    unsigned repeat_entry = 1;
    bool repeat_requested = false;
    for (int i = 2; i < argc; ++i) {
        std::string option = argv[i];
        if (i + 1 == argc || (option != "--args" && option != "--probe" && option != "--fastpcall" && option != "--repeat-entry")) return 2;
        std::string argument = argv[++i];
        if (option == "--fastpcall") {
            if (!fastpcall || (argument != "true" && argument != "false")) {
                std::fprintf(stderr, "requested protected-call runtime flag is unavailable or invalid\n"); return 2;
            }
            fastpcall->value = argument == "true";
            protected_mode_requested = true;
        } else if (option == "--repeat-entry") {
            char* end = nullptr;
            long count = std::strtol(argument.c_str(), &end, 10);
            if (argument.empty() || !end || *end || count < 1 || count > 16) {
                std::fprintf(stderr, "repeat-entry count must be 1..16\n"); return 2;
            }
            repeat_entry = unsigned(count); repeat_requested = true;
        } else (option == "--args" ? args_path : probe_path) = argument;
    }
    Bytes code, args, probe;
    if (!read_file(argv[1], code) || code.empty() || (!args_path.empty() && !read_file(args_path, args)) || (!probe_path.empty() && (!read_file(probe_path, probe) || probe.empty()))) {
        std::fprintf(stderr, "cannot read bounded oracle input\n"); return 2;
    }
    Budget budget;
    budget.observe_protected = protected_mode_requested;
    budget.deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
    lua_State* state = lua_newstate(allocate, &budget);
    if (!state) return 2;
    lua_callbacks(state)->userdata = &budget;
    lua_callbacks(state)->interrupt = [](lua_State* L, int) {
        auto* b = static_cast<Budget*>(lua_callbacks(L)->userdata);
        protected_call_evidence(L, *b);
        if (std::chrono::steady_clock::now() > b->deadline) { b->timed_out = true; luaL_error(L, "oracle execution deadline exceeded"); }
    };
    luaL_openlibs(state);
    lua_pushcfunction(state, print_effect, "print"); lua_setglobal(state, "print");
    lua_pushcfunction(state, warn_effect, "warn"); lua_setglobal(state, "warn");
    luaL_sandbox(state);
    luaL_sandboxthread(state);
    unsigned outcome = 0;
    unsigned entries_invoked = 0;
    int status = luau_load(state, "=test", reinterpret_cast<const char*>(code.data()), code.size(), 0);
    if (status) outcome = 2;
    else {


        int entry_reference = lua_ref(state, -1);
        lua_settop(state, 0);
        int count = 0;
        for (unsigned entry = 0; entry < repeat_entry; ++entry) {
            lua_getref(state, entry_reference);
            count = 0;
            if (!args_path.empty() && !arguments(state, args, count)) { std::fprintf(stderr, "invalid LARG/1 arguments\n"); lua_close(state); return 2; }
            entries_invoked++;
            status = lua_pcall(state, count, LUA_MULTRET, 0);
            if (status || entry + 1 == repeat_entry) break;
            lua_settop(state, 0);
        }
        lua_unref(state, entry_reference);
        if (status) outcome = 1;
        else if (!probe.empty()) {
            count = lua_gettop(state);
            status = luau_load(state, "=probe", reinterpret_cast<const char*>(probe.data()), probe.size(), 0);
            if (!status) { lua_insert(state, 1); status = lua_pcall(state, count, LUA_MULTRET, 0); }
            if (status) { outcome = 3; budget.complete = false; }
        }
    }
    if (budget.oracle_error) { outcome = 3; budget.complete = false; }
    if (status == LUA_ERRMEM) { outcome = 3; budget.complete = false; }
    if (budget.timed_out) { outcome = 4; budget.complete = false; }
    Bytes terminal;
    if (!tuple(state, outcome ? -1 : 1, outcome ? 1u : unsigned(lua_gettop(state)), budget, terminal)) {
        outcome = 3; budget.complete = false;
        terminal.clear(); u32(terminal, 1); byte(terminal, 3);
        const char message[] = "oracle terminal observation budget exceeded";
        u32(terminal, sizeof(message) - 1); raw(terminal, message, sizeof(message) - 1);
    }
    Bytes frame;
    raw(frame, "LOBS\1", 5); byte(frame, budget.complete ? 1 : 0); u32(frame, budget.event_count);
    raw(frame, budget.events.data(), budget.events.size()); byte(frame, outcome);
    if (!raw(frame, terminal.data(), terminal.size())) { std::fprintf(stderr, "oracle frame budget exceeded\n"); lua_close(state); return 2; }
    bool written = std::fwrite(frame.data(), 1, frame.size(), stdout) == frame.size();
    if (protected_mode_requested) std::fprintf(stderr, "FASTPCALL seen=%u eligible=%u enabled=%s eligible_lua=%u eligible_c=%u\n", budget.fastpcall_seen, budget.fastpcall_eligible, fastpcall->value ? "true" : "false", budget.fastpcall_eligible_lua, budget.fastpcall_eligible_c);
    if (repeat_requested) std::fprintf(stderr, "ENTRY invocations=%u requested=%u\n", entries_invoked, repeat_entry);
    lua_close(state);
    return written ? 0 : 2;
}
