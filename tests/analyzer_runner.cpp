

#include "Luau/Ast.h"
#include "Luau/BuiltinDefinitions.h"
#include "Luau/Compiler.h"
#include "Luau/ConfigResolver.h"
#include "Luau/Frontend.h"
#include "Luau/Parser.h"
#include "Luau/Symbol.h"
#include "Luau/ToString.h"
#include "Luau/Type.h"
#include "Luau/TypeArena.h"
#include "Luau/TypePack.h"
#include "Luau/ExperimentalFlags.h"
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <fstream>
#include <filesystem>
#include <iostream>
#include <map>
#include <memory>
#include <limits>
#include <unordered_map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif
#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

static constexpr size_t MaxFrame=16*1024*1024;
LUAU_FASTINT(LuauTypeInferIterationLimit)
LUAU_FASTINT(LuauTypeCloneIterationLimit)
LUAU_FASTINT(LuauTarjanChildLimit)
static std::string json(const std::string& s) {
    static const char* hex="0123456789abcdef";
    std::string out="\"";
    for(unsigned char c:s) {if(c=='\"'||c=='\\'){out+='\\';out+=char(c);}else if(c<32){out+="\\u00";out+=hex[c>>4];out+=hex[c&15];}else out+=char(c);}
    return out+'\"';
}
static uint32_t number(const std::string& s,size_t& p) {
    if(p+4>s.size())throw std::runtime_error("truncated request");
    uint32_t v=0;for(int i=0;i<4;i++)v|=uint32_t(uint8_t(s[p++]))<<(8*i);return v;
}
static std::string field(const std::string& s,size_t& p) {
    size_t n=number(s,p);if(n>MaxFrame||n>s.size()-p)throw std::runtime_error("invalid string length");std::string v=s.substr(p,n);p+=n;return v;
}
static void respond(const std::string& s) {
    if(s.size()>MaxFrame)throw std::runtime_error("response exceeds bound");
    uint32_t n=uint32_t(s.size());char head[4];for(int i=0;i<4;i++)head[i]=char(n>>(8*i));
    std::cout.write(head,4);std::cout.write(s.data(),s.size());std::cout.flush();
}
#ifdef __EMSCRIPTEN__
static std::string browserDefinitions;
#endif
static std::string readfile(const char* path) {
#ifdef __EMSCRIPTEN__
    if(std::string(path)!="browser:pinned"||browserDefinitions.empty())throw std::runtime_error("pinned browser definitions unavailable");
    return browserDefinitions;
#else
    std::ifstream f(std::filesystem::u8path(path),std::ios::binary|std::ios::ate);if(!f)throw std::runtime_error("definition file unavailable");
    auto n=f.tellg();if(n<0||n>4*1024*1024)throw std::runtime_error("definition file exceeds limit");
    std::string s(size_t(n),'\0');f.seekg(0);f.read(s.data(),n);if(!f)throw std::runtime_error("definition read failed");return s;
#endif
}
static std::string expression(Luau::AstExpr* e) {
    if(auto* x=e->as<Luau::AstExprConstantString>())return std::string(x->value.data,x->value.size);
    if(auto* x=e->as<Luau::AstExprGlobal>())return x->name.value;
    if(auto* x=e->as<Luau::AstExprIndexName>()){auto base=expression(x->expr);return base.empty()?"":base+"."+x->index.value;}
    return "";
}
struct Resolver:Luau::FileResolver {
    std::map<std::string,std::string> sources,paths;
    std::set<std::string> missing;
    std::optional<Luau::SourceCode> readSource(const Luau::ModuleName& n) override {
        auto i=sources.find(n);if(i==sources.end())return std::nullopt;return Luau::SourceCode{i->second,Luau::SourceCode::Module};
    }
    std::string resolve(const Luau::ModuleInfo* context,Luau::AstExpr* e) {
        std::string path=expression(e);auto mapped=paths.find(path);
        if(mapped!=paths.end())return mapped->second;
        if(e->is<Luau::AstExprConstantString>()) {
            if(path.rfind("./",0)==0||path.rfind("../",0)==0){
                std::string base=context?context->name:"main";auto slash=base.find_last_of('/');base=slash==std::string::npos?"":base.substr(0,slash+1);
                path=base+path;std::vector<std::string> parts;std::istringstream in(path);std::string part;
                while(std::getline(in,part,'/')){if(part=="."||part.empty())continue;if(part==".."){if(parts.empty())return "";parts.pop_back();}else parts.push_back(part);}
                path.clear();for(auto& x:parts){if(!path.empty())path+='/';path+=x;}
            }
            return path;
        }
        return "";
    }
    std::optional<Luau::ModuleInfo> resolveModule(const Luau::ModuleInfo* c,Luau::AstExpr* e,const Luau::TypeCheckLimits&) override {
        std::string n=resolve(c,e);if(n.empty()||!sources.count(n)){missing.insert(n.empty()?"<dynamic require>":n);return std::nullopt;}return Luau::ModuleInfo{n,false};
    }
};
static std::string diagnostic(const std::string& category,const std::string& message,const std::string& module,const Luau::Location& l) {
    return "{\"category\":"+json(category)+",\"message\":"+json(message)+",\"module\":"+json(module)+",\"line\":"+std::to_string(l.begin.line+1)+",\"column\":"+std::to_string(l.begin.column+1)+",\"end_line\":"+std::to_string(l.end.line+1)+",\"end_column\":"+std::to_string(l.end.column+1)+"}";
}
template<class T>static std::string strings(const T& v){std::string s="[";bool first=true;for(auto&x:v){if(!first)s+=',';first=false;s+=json(x);}return s+"]";}
static std::string diagnostics(const std::vector<std::string>& v){std::string s="[";for(size_t i=0;i<v.size();i++){if(i)s+=',';s+=v[i];}return s+"]";}
struct VisibleTypeGraph {
    static constexpr unsigned Any = 1;
    static constexpr unsigned Unknown = 2;
    static constexpr size_t Missing = std::numeric_limits<size_t>::max();
    struct Key {
        const void* pointer;
        bool pack;
        bool operator==(const Key& other) const { return pointer == other.pointer && pack == other.pack; }
    };
    struct Hash {
        size_t operator()(const Key& key) const { return std::hash<const void*>{}(key.pointer) ^ size_t(key.pack); }
    };
    struct Node {
        Key key;
        unsigned flags = 0;
        std::vector<size_t> parents;
    };
    std::unordered_map<Key, size_t, Hash> indices;
    std::vector<Node> nodes;
    size_t edgeCount = 0;
    size_t maxNodes;
    size_t maxEdges;
    bool exhausted = false;

    explicit VisibleTypeGraph(size_t maxNodes = 100000, size_t maxEdges = 500000)
        : maxNodes(maxNodes), maxEdges(maxEdges) {}

    size_t ensure(Key key) {
        if (!key.pointer) return Missing;
        auto found = indices.find(key);
        if (found != indices.end()) return found->second;
        if (nodes.size() >= maxNodes) { exhausted = true; return Missing; }
        size_t index = nodes.size();
        indices.emplace(key, index);
        nodes.push_back(Node{key, 0, {}});
        return index;
    }
    size_t root(Luau::TypeId type) { return ensure(Key{type, false}); }
    size_t root(Luau::TypePackId pack) { return ensure(Key{pack, true}); }
    bool edge(size_t parent, Key child) {
        if (edgeCount >= maxEdges) { exhausted = true; nodes[parent].flags |= Unknown; return false; }
        size_t index = ensure(child);
        if (index == Missing) { nodes[parent].flags |= Unknown; return !exhausted; }
        nodes[index].parents.push_back(parent);
        ++edgeCount;
        return true;
    }
    bool edge(size_t parent, Luau::TypeId child) { return edge(parent, Key{child, false}); }
    bool edge(size_t parent, Luau::TypePackId child) { return edge(parent, Key{child, true}); }
    void expandType(size_t index, Luau::TypeId type) {
        if (auto* bound = Luau::get_if<Luau::BoundType>(&type->ty)) { edge(index, bound->boundTo); return; }
        if (Luau::get_if<Luau::AnyType>(&type->ty)) { nodes[index].flags |= Any; return; }
        if (Luau::get_if<Luau::UnknownType>(&type->ty)
            || Luau::get_if<Luau::FreeType>(&type->ty)
            || Luau::get_if<Luau::BlockedType>(&type->ty)
            || Luau::get_if<Luau::ErrorType>(&type->ty)) {
            nodes[index].flags |= Unknown;
            return;
        }
        if (auto* function = Luau::get_if<Luau::FunctionType>(&type->ty)) {
            if (!edge(index, function->argTypes) || !edge(index, function->retTypes)) return;
            for (auto child : function->generics) if (!edge(index, child)) return;
            for (auto child : function->genericPacks) if (!edge(index, child)) return;
        } else if (auto* table = Luau::get_if<Luau::TableType>(&type->ty)) {
            if (table->boundTo) { edge(index, *table->boundTo); return; }
            for (auto& property : table->props) {
                if (property.second.readTy && !edge(index, *property.second.readTy)) return;
                if (property.second.writeTy && property.second.writeTy != property.second.readTy
                    && !edge(index, *property.second.writeTy)) return;
            }
            if (table->indexer && (!edge(index, table->indexer->indexType) || !edge(index, table->indexer->indexResultType))) return;
            for (auto child : table->instantiatedTypeParams) if (!edge(index, child)) return;
            for (auto child : table->instantiatedTypePackParams) if (!edge(index, child)) return;
        } else if (auto* metatable = Luau::get_if<Luau::MetatableType>(&type->ty)) {
            if (!edge(index, metatable->table)) return;
            edge(index, metatable->metatable);
        } else if (auto* options = Luau::get_if<Luau::UnionType>(&type->ty)) {
            for (auto child : options->options) if (!edge(index, child)) return;
        } else if (auto* parts = Luau::get_if<Luau::IntersectionType>(&type->ty)) {
            for (auto child : parts->parts) if (!edge(index, child)) return;
        } else if (auto* negation = Luau::get_if<Luau::NegationType>(&type->ty)) {
            edge(index, negation->ty);
        } else if (auto* lazy = Luau::get_if<Luau::LazyType>(&type->ty)) {
            auto unwrapped = lazy->unwrapped.load();
            if (unwrapped) edge(index, unwrapped);
            else nodes[index].flags |= Unknown;
        } else if (auto* application = Luau::get_if<Luau::TypeFunctionInstanceType>(&type->ty)) {
            if (application->state != Luau::TypeFunctionInstanceState::Solved) nodes[index].flags |= Unknown;
            for (auto child : application->typeArguments) if (!edge(index, child)) return;
            for (auto child : application->packArguments) if (!edge(index, child)) return;
        } else if (auto* pending = Luau::get_if<Luau::PendingExpansionType>(&type->ty)) {
            nodes[index].flags |= Unknown;
            for (auto child : pending->typeArguments) if (!edge(index, child)) return;
            for (auto child : pending->packArguments) if (!edge(index, child)) return;
        } else if (auto* primitive = Luau::get_if<Luau::PrimitiveType>(&type->ty)) {
            if (primitive->type == Luau::PrimitiveType::Function || primitive->type == Luau::PrimitiveType::Table)
                nodes[index].flags |= Unknown;
        }
    }
    void expandPack(size_t index, Luau::TypePackId pack) {
        if (auto* bound = Luau::get_if<Luau::BoundTypePack>(&pack->ty)) { edge(index, bound->boundTo); return; }
        if (auto* list = Luau::get_if<Luau::TypePack>(&pack->ty)) {
            for (auto child : list->head) if (!edge(index, child)) return;
            if (list->tail) edge(index, *list->tail);
        } else if (auto* variadic = Luau::get_if<Luau::VariadicTypePack>(&pack->ty)) {
            if (!variadic->hidden) edge(index, variadic->ty);
        } else if (auto* application = Luau::get_if<Luau::TypeFunctionInstanceTypePack>(&pack->ty)) {
            nodes[index].flags |= Unknown;
            for (auto child : application->typeArguments) if (!edge(index, child)) return;
            for (auto child : application->packArguments) if (!edge(index, child)) return;
        } else if (!Luau::get_if<Luau::GenericTypePack>(&pack->ty)) {
            nodes[index].flags |= Unknown;
        }
    }
    void finish() {
        size_t next = 0;
        for (; next < nodes.size() && !exhausted; ++next) {
            Key key = nodes[next].key;
            if (key.pack) expandPack(next, static_cast<Luau::TypePackId>(key.pointer));
            else expandType(next, static_cast<Luau::TypeId>(key.pointer));
        }
        for (size_t index = next; index < nodes.size(); ++index) nodes[index].flags |= Unknown;
        std::vector<size_t> pending;
        for (size_t index = 0; index < nodes.size(); ++index) if (nodes[index].flags) pending.push_back(index);
        for (size_t cursor = 0; cursor < pending.size(); ++cursor) {
            size_t child = pending[cursor];
            for (size_t parent : nodes[child].parents) {
                unsigned flags = nodes[parent].flags | nodes[child].flags;
                if (flags != nodes[parent].flags) { nodes[parent].flags = flags; pending.push_back(parent); }
            }
        }
    }
    unsigned flags(size_t index) const { return index < nodes.size() ? nodes[index].flags : Unknown; }
};

static Luau::TypeId originType(Luau::TypeId type) {
    for (size_t hop = 0; type && hop < 256; ++hop) {
        if (auto* bound = Luau::get_if<Luau::BoundType>(&type->ty)) type = bound->boundTo;
        else if (auto* lazy = Luau::get_if<Luau::LazyType>(&type->ty)) type = lazy->unwrapped.load();
        else return type;
    }
    return nullptr;
}
static bool sdkType(Luau::TypeId type) {
    type = originType(type);
    if (!type || !type->persistent) return false;
    auto sdk = [](const std::string& name) { return name == "@luau" || name == "Roblox"; };
    if (type->documentationSymbol
        && (type->documentationSymbol->rfind("@luau/", 0) == 0 || type->documentationSymbol->rfind("Roblox/", 0) == 0)) return true;
    if (auto* function = Luau::get_if<Luau::FunctionType>(&type->ty))
        return function->definition && function->definition->definitionModuleName && sdk(*function->definition->definitionModuleName);
    if (auto* table = Luau::get_if<Luau::TableType>(&type->ty)) return sdk(table->definitionModuleName);
    return false;
}
static bool sdkExpression(const Luau::AstExpr* expression, Luau::TypeId type, Luau::Frontend& frontend) {
    if (sdkType(type)) return true;
    auto origin = originType(type);
    if (!origin || !origin->persistent) return false;
    while (auto* group = expression->as<Luau::AstExprGroup>()) expression = group->expr;
    auto* global = expression->as<Luau::AstExprGlobal>();
    if (!global) return false;
    auto binding = Luau::tryGetGlobalBinding(frontend.globals, global->name.value);
    if (!binding || originType(binding->typeId) != origin || !binding->documentationSymbol) return false;
    auto& name = *binding->documentationSymbol;
    return name.rfind("@luau/", 0) == 0 || name.rfind("Roblox/", 0) == 0;
}
struct Inspect:Luau::AstVisitor {
    Luau::Frontend& frontend;Luau::ModulePtr module;Resolver& resolver;std::string name;
    size_t explicitAny=0,assertions=0;std::set<std::string> globals;
    std::set<const Luau::AstExpr*> callees,qualifiers;
    Inspect(Luau::Frontend& f,Luau::ModulePtr m,Resolver&r,std::string n):frontend(f),module(m),resolver(r),name(n){}
    bool visit(Luau::AstExprGlobal* e) override {if(!frontend.globals.globalScope->lookup(Luau::Symbol(e->name)))globals.insert(e->name.value);return true;}
    bool visit(Luau::AstTypeReference* t) override {if(std::string(t->name.value)=="any")explicitAny++;return true;}
    bool visit(Luau::AstExprTypeAssertion*) override {assertions++;return true;}
    void context(std::set<const Luau::AstExpr*>& expressions, Luau::AstExpr* expression) {
        for (;;) {
            expressions.insert(expression);
            if (auto* group = expression->as<Luau::AstExprGroup>()) expression = group->expr;
            else return;
        }
    }
    bool visit(Luau::AstExprIndexName* e) override {context(qualifiers,e->expr);return true;}
    bool visit(Luau::AstExprIndexExpr* e) override {context(qualifiers,e->expr);return true;}
    bool visit(Luau::AstExprCall* e) override {
        context(callees,e->func);
        if(auto* g=e->func->as<Luau::AstExprGlobal>();g&&std::string(g->name.value)=="require"&&e->args.size) {
            Luau::ModuleInfo context{name,false};auto n=resolver.resolve(&context,e->args.data[0]);
            if(n.empty()||!resolver.sources.count(n))resolver.missing.insert(n.empty()?"<dynamic require>":n);
        }
        return true;
    }
};
struct NoTypeExecution:Luau::AstVisitor {
    std::vector<Luau::Location> rejected;
    bool visit(Luau::AstStatTypeFunction* node)override{rejected.push_back(node->location);return false;}
};
static bool typeQualitySelfTest() {
    Luau::TypeArena arena;
    auto numberType = arena.addType(Luau::PrimitiveType{Luau::PrimitiveType::Number});
    auto anyType = arena.addType(Luau::AnyType{});
    auto first = arena.addType(Luau::TableType{});
    auto second = arena.addType(Luau::TableType{});
    Luau::getMutable<Luau::TableType>(first)->props["next"] = Luau::Property::rw(second);
    Luau::getMutable<Luau::TableType>(second)->props["next"] = Luau::Property::rw(first);
    Luau::getMutable<Luau::TableType>(second)->props["value"] = Luau::Property::rw(numberType);
    VisibleTypeGraph clean;
    auto cleanRoot = clean.root(first);
    clean.finish();
    bool cycleClean = !clean.exhausted && clean.flags(cleanRoot) == 0;
    Luau::getMutable<Luau::TableType>(second)->props["value"] = Luau::Property::rw(anyType);
    VisibleTypeGraph dynamic;
    auto dynamicRoot = dynamic.root(first);
    dynamic.finish();
    bool cycleAny = !dynamic.exhausted && (dynamic.flags(dynamicRoot) & VisibleTypeGraph::Any);
    VisibleTypeGraph nodeLimited(1, 100);
    auto nodeRoot = nodeLimited.root(first);
    nodeLimited.finish();
    VisibleTypeGraph edgeLimited(100, 1);
    auto edgeRoot = edgeLimited.root(first);
    edgeLimited.finish();
    bool nodeBudget = nodeLimited.exhausted && (nodeLimited.flags(nodeRoot) & VisibleTypeGraph::Unknown);
    bool edgeBudget = edgeLimited.exhausted && (edgeLimited.flags(edgeRoot) & VisibleTypeGraph::Unknown);
    auto empty = arena.addTypePack({});
    auto hiddenPack = arena.addTypePack(Luau::VariadicTypePack{anyType, true});
    auto visiblePack = arena.addTypePack(Luau::VariadicTypePack{anyType, false});
    auto hiddenFunction = arena.addType(Luau::FunctionType{hiddenPack, empty});
    auto visibleFunction = arena.addType(Luau::FunctionType{visiblePack, empty});
    VisibleTypeGraph packs;
    auto hiddenRoot = packs.root(hiddenFunction);
    auto visibleRoot = packs.root(visibleFunction);
    packs.finish();
    bool hiddenClean = packs.flags(hiddenRoot) == 0;
    bool visibleAny = (packs.flags(visibleRoot) & VisibleTypeGraph::Any) != 0;
    bool passed = cycleClean && cycleAny && nodeBudget && edgeBudget && hiddenClean && visibleAny;
    std::cout << "{\"passed\":" << (passed ? "true" : "false")
        << ",\"cycle_clean\":" << (cycleClean ? "true" : "false")
        << ",\"cycle_any_reached\":" << (cycleAny ? "true" : "false")
        << ",\"node_budget_unknown\":" << (nodeBudget ? "true" : "false")
        << ",\"edge_budget_unknown\":" << (edgeBudget ? "true" : "false")
        << ",\"hidden_variadic_clean\":" << (hiddenClean ? "true" : "false")
        << ",\"visible_variadic_any\":" << (visibleAny ? "true" : "false") << "}\n";
    return passed;
}
struct AnalysisRequest {
    std::string entry, source, extra;
    uint32_t timeout;
    std::map<std::string,std::string> sources, paths;
};
static AnalysisRequest decodeRequest(const std::string& request) {
    size_t position=0;
    if(field(request,position)!="LQRY/1")throw std::runtime_error("request protocol mismatch");
    AnalysisRequest result;
    result.entry=field(request,position);result.source=field(request,position);result.extra=field(request,position);result.timeout=number(request,position);
    if(result.timeout<100||result.timeout>120000)throw std::runtime_error("invalid deadline");
    result.sources.emplace(result.entry,result.source);
    auto readmap=[&](auto& target,size_t maximum){uint32_t count=number(request,position);if(count>maximum)throw std::runtime_error("map limit");for(uint32_t index=0;index<count;index++){auto key=field(request,position),value=field(request,position);if(!target.emplace(key,value).second)throw std::runtime_error("duplicate module/path");}};
    readmap(result.sources,256);readmap(result.paths,1024);
    if(position!=request.size())throw std::runtime_error("trailing request bytes");
    return result;
}
static void analysisFlags() {
    for(auto* flag=Luau::FValue<bool>::list;flag;flag=flag->next)
        if(std::string(flag->name).rfind("Luau",0)==0&&!Luau::isAnalysisFlagExperimental(flag->name))flag->value=true;
}
struct DefinitionLimits {
    int iterations=FInt::LuauTypeInferIterationLimit.value;
    int clones=FInt::LuauTypeCloneIterationLimit.value;
    int children=FInt::LuauTarjanChildLimit.value;
    DefinitionLimits(){FInt::LuauTypeInferIterationLimit.value=1000000;FInt::LuauTypeCloneIterationLimit.value=2000000;FInt::LuauTarjanChildLimit.value=1000000;}
    ~DefinitionLimits(){FInt::LuauTypeInferIterationLimit.value=iterations;FInt::LuauTypeCloneIterationLimit.value=clones;FInt::LuauTarjanChildLimit.value=children;}
};
struct AnalyzerContext {
    struct StrictConfig:Luau::NullConfigResolver {StrictConfig(){defaultConfig.mode=Luau::Mode::Strict;}};
    Resolver resolver;
    StrictConfig config;
    Luau::FrontendOptions options;
    Luau::Frontend frontend;
    std::string projectDefinitions;
    bool projectLoaded=false;
    std::vector<std::string> bootstrap;
    explicit AnalyzerContext(const std::string& definitions):frontend(Luau::SolverMode::New,&resolver,&config,settings()) {
        options=settings();
        Luau::registerBuiltinGlobals(frontend,frontend.globals);
        DefinitionLimits limits;
        auto loaded=frontend.loadDefinitionFile(frontend.globals,frontend.globals.globalScope,definitions,"Roblox",false);
        for(auto& error:loaded.parseResult.errors)bootstrap.push_back(diagnostic("definitions_syntax",error.getMessage(),"Roblox",error.getLocation()));
        if(loaded.module)for(auto& error:loaded.module->errors)bootstrap.push_back(diagnostic("definitions_type",Luau::toString(error),"Roblox",error.location));
        if(!loaded.success&&bootstrap.empty())bootstrap.push_back(diagnostic("definitions","pinned definitions rejected","Roblox",{}));
    }
    static Luau::FrontendOptions settings(){Luau::FrontendOptions value;value.retainFullTypeGraphs=true;value.runLintChecks=false;value.moduleTimeLimitSec=5.0;return value;}
    bool compatible(const AnalysisRequest& request) const {return !projectLoaded||projectDefinitions==request.extra;}
    void process(const AnalysisRequest& request) {
        if(!bootstrap.empty()){respond("{\"ready\":false,\"diagnostics\":"+diagnostics(bootstrap)+"}");return;}
        auto& entry=request.entry;auto& source=request.source;auto timeout=request.timeout;
        frontend.clear();frontend.clearStats();resolver.sources=request.sources;resolver.paths=request.paths;resolver.missing.clear();
        std::vector<std::string> errors;
        if(!compatible(request))throw std::runtime_error("worker project contract changed");
        if(!projectLoaded){
            projectDefinitions=request.extra;projectLoaded=true;
            if(!projectDefinitions.empty()){
                auto loaded=frontend.loadDefinitionFile(frontend.globals,frontend.globals.globalScope,projectDefinitions,"ProjectContract",false);
                for(auto& error:loaded.parseResult.errors)errors.push_back(diagnostic("contract_syntax",error.getMessage(),"ProjectContract",error.getLocation()));
                if(loaded.module)for(auto& error:loaded.module->errors)errors.push_back(diagnostic("contract_type",Luau::toString(error),"ProjectContract",error.location));
                if(!loaded.success&&errors.empty())errors.push_back(diagnostic("contract","definition contract rejected","ProjectContract",{}));
            }
            if(errors.empty())Luau::freeze(frontend.globals.globalTypes);
        }
        if(!errors.empty()){bootstrap=errors;respond("{\"syntax\":false,\"compilation\":false,\"strict\":false,\"diagnostics\":"+diagnostics(errors)+"}");return;}
        Luau::CompileOptions compileOptions;compileOptions.optimizationLevel=0;compileOptions.debugLevel=0;
        auto compileStart=std::chrono::steady_clock::now();auto bytecode=Luau::compile(source,compileOptions);bool compiled=!bytecode.empty()&&uint8_t(bytecode[0])!=0;
        auto compilerMicros=std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now()-compileStart).count();
        auto analysisStart=std::chrono::steady_clock::now();bool mainSyntax=true;


        for(auto& item:resolver.sources){Luau::Allocator allocator;Luau::AstNameTable names(allocator);auto parsed=Luau::Parser::parse(item.second.data(),item.second.size(),names,allocator);
            if(item.first==entry)mainSyntax=parsed.errors.empty();
            if(parsed.root){NoTypeExecution inspect;parsed.root->visit(&inspect);for(auto& loc:inspect.rejected)errors.push_back(diagnostic("unsupported_type_function","user-defined type functions are not executed by this static-only validator",item.first,loc));}}
        if(!errors.empty()){respond("{\"syntax\":"+std::string(mainSyntax?"true":"false")+",\"compilation\":"+std::string(compiled?"true":"false")+",\"strict\":false,\"diagnostics\":"+diagnostics(errors)+"}");return;}
        auto checkOptions=options;checkOptions.moduleTimeLimitSec=double(timeout)/1000.0;auto checked=frontend.check(entry,checkOptions);
        bool syntax=mainSyntax;for(auto&e:checked.errors){bool parse=Luau::get_if<Luau::SyntaxError>(&e.data)!=nullptr;errors.push_back(diagnostic(parse?"syntax":"type",Luau::toString(e),e.moduleName,e.location));}
        size_t explicitAny=0,inferredAny=0,inferredUnknown=0,assertions=0,expressions=0;std::set<std::string> globals;
        VisibleTypeGraph visibleTypes;
        std::vector<std::pair<size_t,size_t>> visibleRoots;
        for(auto& item:resolver.sources){auto* sm=frontend.getSourceModule(item.first);auto module=frontend.moduleResolver.getModule(item.first);if(!sm||!sm->root||!module)continue;
            if(sm->mode&&*sm->mode!=Luau::Mode::Strict)errors.push_back(diagnostic("mode","strict validation cannot accept a disabling directive",item.first,{}));
            Inspect inspect(frontend,module,resolver,item.first);sm->root->visit(&inspect);explicitAny+=inspect.explicitAny;assertions+=inspect.assertions;globals.insert(inspect.globals.begin(),inspect.globals.end());
            std::map<const Luau::AstExpr*,std::pair<Luau::TypeId,Luau::TypePackId>> roots;
            for(auto& type:module->astTypes)roots[type.first].first=type.second;
            for(auto& pack:module->astTypePacks)roots[pack.first].second=pack.second;
            for(auto& root:roots) {
                auto type=root.second.first;
                auto origin=originType(type);
                bool callee=inspect.callees.count(root.first)&&origin&&Luau::get_if<Luau::FunctionType>(&origin->ty);
                bool qualifier=inspect.qualifiers.count(root.first)&&origin&&Luau::get_if<Luau::TableType>(&origin->ty);
                if((callee||qualifier)&&sdkExpression(root.first,type,frontend))continue;
                visibleRoots.emplace_back(type?visibleTypes.root(type):VisibleTypeGraph::Missing,
                root.second.second?visibleTypes.root(root.second.second):VisibleTypeGraph::Missing);
            }
        }
        visibleTypes.finish();
        for(auto root:visibleRoots) {
            unsigned flags=0;
            if(root.first!=VisibleTypeGraph::Missing)flags|=visibleTypes.flags(root.first);
            if(root.second!=VisibleTypeGraph::Missing)flags|=visibleTypes.flags(root.second);
            expressions++;
            if(flags&VisibleTypeGraph::Any)inferredAny++;
            if(flags&VisibleTypeGraph::Unknown)inferredUnknown++;
        }
        for(auto& n:resolver.missing)errors.push_back(diagnostic("dependency","unresolved static/dynamic dependency: "+n,entry,{}));
        for(auto& n:checked.timeoutHits)errors.push_back(diagnostic("deadline","analyzer module deadline exceeded",n,{}));
        bool strict=errors.empty();
        if(visibleTypes.exhausted) {
            inferredUnknown=std::max<size_t>(inferredUnknown,1);
            errors.push_back(diagnostic("type_quality_budget","visible expression type/pack traversal exceeded its 100000-node or 500000-edge budget; type counts are incomplete lower bounds",entry,{}));
        }
        auto analyzerMicros=std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now()-analysisStart).count();
        respond("{\"syntax\":"+std::string(syntax?"true":"false")+",\"compilation\":"+(compiled?"true":"false")+",\"strict\":"+(strict?"true":"false")+",\"diagnostics\":"+diagnostics(errors)+",\"missing_dependencies\":"+strings(resolver.missing)+",\"external_globals\":"+strings(globals)+",\"explicit_any\":"+std::to_string(explicitAny)+",\"inferred_any\":"+std::to_string(inferredAny)+",\"inferred_unknown\":"+std::to_string(inferredUnknown)+",\"type_traversal_exhausted\":"+(visibleTypes.exhausted?"true":"false")+",\"type_assertions\":"+std::to_string(assertions)+",\"expressions_analyzed\":"+std::to_string(expressions)+",\"compiler_micros\":"+std::to_string(compilerMicros)+",\"analyzer_micros\":"+std::to_string(analyzerMicros)+"}");
    }
};
static int run(int argc,char**argv) {
    if(argc==2&&std::string(argv[1])=="--version"){std::cout<<"LQUAL/1 Luau0.746 12a6ba75883272c79b66b59815efef4c574196f6\n";return 0;}
    if(argc==2&&std::string(argv[1])=="--type-quality-self-test")return typeQualitySelfTest()?0:2;
#ifdef _WIN32
    _setmode(_fileno(stdin),_O_BINARY);_setmode(_fileno(stdout),_O_BINARY);
#endif
    try {
        if(argc!=2)throw std::runtime_error("expected pinned definition file");
        analysisFlags();
        std::string definitions=readfile(argv[1]);
        auto context=std::make_unique<AnalyzerContext>(definitions);
        if(!context->bootstrap.empty()){respond("{\"ready\":false,\"diagnostics\":"+diagnostics(context->bootstrap)+"}");return 2;}
        respond("{\"ready\":true,\"protocol\":\"LQUAL/1\"}");
        for(;;){
            char header[4];std::cin.read(header,4);if(std::cin.gcount()==0)return 0;if(std::cin.gcount()!=4)throw std::runtime_error("truncated frame header");
            uint32_t length=0;for(int index=0;index<4;index++)length|=uint32_t(uint8_t(header[index]))<<(8*index);if(length>MaxFrame)throw std::runtime_error("request too large");
            std::string bytes(length,'\0');std::cin.read(bytes.data(),length);if(!std::cin)throw std::runtime_error("truncated frame");
            auto request=decodeRequest(bytes);
            if(!context->compatible(request))context=std::make_unique<AnalyzerContext>(definitions);
            context->process(request);
        }
    }catch(const std::exception& error){try{respond("{\"ready\":false,\"error\":"+json(error.what())+"}");}catch(...){}return 2;}
}

#ifdef __EMSCRIPTEN__
static std::string browserResult;
static std::unique_ptr<AnalyzerContext> browserContext;
struct BrowserStreams {
    std::istringstream input;
    std::ostringstream output;
    std::streambuf* previousInput;
    std::streambuf* previousOutput;
    explicit BrowserStreams(const std::string& frame):input(frame),previousInput(std::cin.rdbuf(input.rdbuf())),previousOutput(std::cout.rdbuf(output.rdbuf())){std::cin.clear();std::cout.clear();}
    ~BrowserStreams(){std::cin.rdbuf(previousInput);std::cout.rdbuf(previousOutput);std::cin.clear();std::cout.clear();}
};
extern "C" {
EMSCRIPTEN_KEEPALIVE int luau_quality_set_definitions(const char* data,size_t length){
    if(!data||length==0||length>4*1024*1024)return 0;
    try{
        std::string definitions(data,length);
        if(browserContext&&browserDefinitions==definitions)return browserContext->bootstrap.empty()?1:0;
        browserContext.reset();browserDefinitions=std::move(definitions);analysisFlags();
        browserContext=std::make_unique<AnalyzerContext>(browserDefinitions);
        return browserContext->bootstrap.empty()?1:0;
    }catch(...){browserContext.reset();return 0;}
}
EMSCRIPTEN_KEEPALIVE const char* luau_quality_validate(const char* data,size_t length){
    try{
        if(!data||length>MaxFrame)throw std::runtime_error("browser request exceeds bound");
        if(browserDefinitions.empty())throw std::runtime_error("pinned browser definitions unavailable");
        auto request=decodeRequest(std::string(data,length));
        bool reused=browserContext&&browserContext->compatible(request);
        auto initializationStart=std::chrono::steady_clock::now();
        if(!reused){browserContext.reset();browserContext=std::make_unique<AnalyzerContext>(browserDefinitions);}
        auto initializationMicros=std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now()-initializationStart).count();
        BrowserStreams streams("");
        browserContext->process(request);
        std::string output=streams.output.str();size_t position=0;
        size_t size=number(output,position);
        if(size>MaxFrame||size!=output.size()-position)throw std::runtime_error("invalid browser response frame");
        browserResult=output.substr(position,size);
        if(browserResult.empty()||browserResult.back()!='}')throw std::runtime_error("invalid browser response object");
        browserResult.pop_back();browserResult+=",\"context_reused\":"+std::string(reused?"true":"false")+",\"context_initialization_micros\":"+std::to_string(initializationMicros)+"}";
    }catch(const std::exception& error){browserContext.reset();browserResult="{\"ready\":false,\"error\":"+json(error.what())+"}";}
    return browserResult.c_str();
}
EMSCRIPTEN_KEEPALIVE size_t luau_quality_result_length(){return browserResult.size();}
}
#elif defined(_WIN32)
int wmain(int argc,wchar_t** wide) {
    try {
        std::vector<std::string> arguments;
        arguments.reserve(size_t(argc));
        for(int i=0;i<argc;i++)arguments.push_back(std::filesystem::path(wide[i]).u8string());
        std::vector<char*> pointers;
        pointers.reserve(size_t(argc)+1);
        for(auto& argument:arguments)pointers.push_back(argument.data());
        pointers.push_back(nullptr);
        return run(argc,pointers.data());
    } catch(const std::exception& e) {try{respond("{\"ready\":false,\"error\":"+json(e.what())+"}");}catch(...){}return 2;}
}
#else
int main(int argc,char** argv) {return run(argc,argv);}
#endif
