pub const PROGRAMS: usize = 128;
pub const FAMILIES: &[&str] = &[
    "arithmetic",
    "branches",
    "while_repeat",
    "numeric_for",
    "tables_aliases",
    "captures",
    "multiple_returns",
    "metamethods",
];
struct Random(u64);
impl Random {
    fn next(&mut self, limit: u64) -> i64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        (self.0 % limit) as i64
    }
}
pub fn program(index: usize) -> String {
    program_from_axes(index % FAMILIES.len(), index)
}

pub fn program_from_axes(family: usize, seed: usize) -> String {
    assert!(family < FAMILIES.len());
    let index = seed;
    let mut random =
        Random(0xb167_882a_c40d_391fu64 ^ (index as u64 + 1).wrapping_mul(0x9e37_79b9_7f4a_7c15));
    let a = random.next(19) + 1;
    let b = random.next(11) + 1;
    let limit = random.next(5) + 2;
    let mut source=format!("-- deterministic valid grammar seed {index}\nlocal seed, token = ...\nlocal total = seed + {a}\nlocal effects = 0\nlocal function mark(value)\n    effects += 1\n    print(\"mark\", effects, value, token)\n    return value\nend\n");
    let fragment=match family {
        0=>format!("local left = (total * {b} - seed) / {b}\nlocal right = -(seed - {a}) ^ 2\ntotal = left + right % {a}\n"),
        1=>format!("if seed < 0 then\n    local value = total * {b}\n    if value < 0 then total = -value else total = value + {a} end\nelseif seed == 0 then\n    total += {b}\nelse\n    local value = total - {a}\n    total = value * {b}\nend\n"),
        2=>format!("local index = 0\nwhile index < {limit} do\n    index += 1\n    if index == 2 then continue end\n    total += index * {a}\nend\nrepeat\n    total -= {b}\n    index -= 1\nuntil index <= 0\n"),
        3=>format!("for index = {limit}, 1, -1 do\n    if index == 2 and seed < 0 then break end\n    total += index * {b}\nend\nfor index = 1, {limit} do\n    if index % 2 == 0 then continue end\n    total -= index + {a}\nend\n"),
        4=>format!("local values = {{{a}, {b}, {limit}}}\nfor index, value in ipairs(values) do total += index * value end\nlocal dictionary = {{}}\nlocal key = \"key\" .. tostring(seed)\ndictionary[key] = total\ntotal = dictionary[key] + #values\n"),
        5=>format!("local function counter(start)\n    local current = start\n    return function(step)\n        current += step\n        return current\n    end\nend\nlocal first = counter(total)\nlocal second = counter(seed)\nlocal left = first({a})\nlocal right = first(-{b})\ntotal = left + right + second({limit})\n"),
        6=>format!("local function many(...)\n    return select(\"#\", ...), ...\nend\nlocal count, first, missing, last = many(total, nil, \"bytes\\000\\255\\t\")\nassert(count == 3 and missing == nil)\nprint(\"tuple\", count, first, missing, last)\ntotal = first + count * {b}\n"),
        _=>format!("local object = setmetatable({{value = total}}, {{__add = function(left, right)\n    return left.value + right.value + {b}\nend}})\nlocal other = {{value = {a}}}\ntotal = object + other\n"),
    };
    source.push_str(&fragment);
    source.push_str("local selected = (total > seed and mark(total)) or mark(seed)\nassert(effects == 1)\nreturn total, selected, effects, nil, \"bytes\\000\\255\\t\", token\n");
    source
}

pub fn compositional_stateful_program(seed: usize) -> String {
    let mut random =
        Random(0xc017_5ed0_9a31_482fu64 ^ (seed as u64 + 1).wrapping_mul(0x9e37_79b9_7f4a_7c15));
    let offset = random.next(17) + 1;
    let scale = random.next(7) + 1;
    let limit = random.next(3) + 2;
    format!(
        r#"-- deterministic compositional seed {seed}
local initial, token = ...
local state = {{ value = initial + {offset} }}
local alias = state
local function step(delta)
    alias.value += delta
    local callbacks = {{}}
    for index = 1, {limit} do
        local snapshot = index
        callbacks[index] = function(extra)
            alias.value += snapshot + extra
            return alias.value
        end
    end
    for index = 1, #callbacks do
        if index == 2 and delta == 0 then continue end
        local value = callbacks[index]({scale})
        if value % 2 == 0 then
            alias.value += index
        else
            alias.value -= index
        end
        print("composed", delta, index, alias.value, token)
    end
    if delta < 0 then error("composed error\000\255", 0) end
    return alias.value, nil, token, nil
end
return function(delta)
    return pcall(step, delta)
end
"#
    )
}
