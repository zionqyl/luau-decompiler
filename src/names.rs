use crate::NameStyle;
use std::collections::{HashMap, HashSet};

const KEYWORDS: &[&str] = &[
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local",
    "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
];

pub fn is_identifier(input: &str) -> bool {
    let mut chars = input.bytes();
    matches!(chars.next(), Some(b'a'..=b'z' | b'A'..=b'Z' | b'_'))
        && chars.all(|b| b.is_ascii_alphanumeric() || b == b'_')
        && !KEYWORDS.contains(&input)
}

pub fn identifier(input: &str, style: NameStyle) -> String {
    let mut end = input.len().min(512);
    while !input.is_char_boundary(end) {
        end -= 1;
    }
    let input = &input[..end];
    let bytes = input.as_bytes();
    let mut words = Vec::new();
    let mut start = 0;
    for i in 0..=bytes.len() {
        let separator = i == bytes.len() || !bytes[i].is_ascii_alphanumeric();
        let boundary = i > start
            && i < bytes.len()
            && bytes[i].is_ascii_uppercase()
            && (bytes[i - 1].is_ascii_lowercase()
                || bytes[i - 1].is_ascii_digit()
                || (bytes[i - 1].is_ascii_uppercase()
                    && bytes.get(i + 1).is_some_and(u8::is_ascii_lowercase)));
        if separator || boundary {
            if start < i {
                words.push(input[start..i].to_ascii_lowercase());
            }
            start = if separator { i + 1 } else { i };
        }
    }
    if words.is_empty() {
        words.push("value".into());
    }
    let mut output = String::new();
    for (i, word) in words.iter().enumerate() {
        if style == NameStyle::SnakeCase {
            if i > 0 {
                output.push('_');
            }
            output.push_str(word);
        } else if style == NameStyle::PascalCase || i > 0 {
            output.push(word.as_bytes()[0].to_ascii_uppercase() as char);
            output.push_str(&word[1..]);
        } else {
            output.push_str(word);
        }
    }
    if output.as_bytes()[0].is_ascii_digit() {
        output.insert_str(0, "value_");
    }
    output.truncate(128);
    if KEYWORDS.contains(&output.as_str())
        || matches!(output.as_str(), "continue" | "type" | "export")
    {
        output.push('_');
    }
    output
}

pub fn quote(bytes: &[u8]) -> String {
    use std::fmt::Write;
    let mut output = String::with_capacity(bytes.len() + 2);
    output.push('"');
    for &b in bytes {
        match b {
            b'"' => output.push_str("\\\""),
            b'\\' => output.push_str("\\\\"),
            b'\n' => output.push_str("\\n"),
            b'\r' => output.push_str("\\r"),
            b'\t' => output.push_str("\\t"),
            32..=126 => output.push(b as char),
            _ => {
                write!(output, "\\{b:03}").unwrap();
            }
        }
    }
    output.push('"');
    output
}

#[derive(Clone)]
pub struct NameAllocator {
    used: HashSet<String>,
    next_suffix: HashMap<String, usize>,
    style: NameStyle,
}
impl NameAllocator {
    pub fn new(style: NameStyle, reserved: impl IntoIterator<Item = String>) -> Self {
        Self {
            used: reserved.into_iter().collect(),
            next_suffix: HashMap::new(),
            style,
        }
    }
    pub fn allocate(&mut self, hint: &str) -> String {
        let base = identifier(hint, self.style);
        if self.used.insert(base.clone()) {
            return base;
        }
        let mut suffix = self.next_suffix.get(&base).copied().unwrap_or(2);
        loop {
            let name = if self.style == NameStyle::SnakeCase {
                format!("{base}_{suffix}")
            } else {
                format!("{base}{suffix}")
            };
            if self.used.insert(name.clone()) {
                self.next_suffix.insert(base, suffix + 1);
                return name;
            }
            suffix += 1;
        }
    }
    pub fn reserve(&mut self, name: &str) -> bool {
        self.used.insert(name.to_owned())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn hints_are_sanitized_and_collision_safe() {
        assert_eq!(
            identifier("HTTPServer.count", NameStyle::SnakeCase),
            "http_server_count"
        );
        assert_eq!(
            identifier("player_score", NameStyle::CamelCase),
            "playerScore"
        );
        assert_eq!(
            identifier("playerScore", NameStyle::PascalCase),
            "PlayerScore"
        );
        assert_eq!(identifier("end", NameStyle::SnakeCase), "end_");
        assert_eq!(identifier("こんにちは", NameStyle::SnakeCase), "value");
        let mut allocator = NameAllocator::new(NameStyle::SnakeCase, ["print".into()]);
        assert_eq!(allocator.allocate("print"), "print_2");
        assert_eq!(allocator.allocate("print"), "print_3");
        let mut allocator = NameAllocator::new(
            NameStyle::SnakeCase,
            ["x".into(), "x_2".into(), "x_4".into()],
        );
        assert_eq!(allocator.allocate("x"), "x_3");
        assert_eq!(allocator.allocate("x"), "x_5");
        assert_eq!(
            identifier(&"long_name_".repeat(10000), NameStyle::CamelCase).len(),
            128
        );
    }
    #[test]
    fn strings_roundtrip_bytes_without_digit_ambiguity() {
        assert_eq!(
            quote(&[0, b'9', b'"', b'\\', 255]),
            "\"\\0009\\\"\\\\\\255\""
        );
        assert!(!is_identifier("for"));
        assert!(!is_identifier("a.b"));
        assert!(is_identifier("_a2"));
        assert!(is_identifier("type"));
        assert!(is_identifier("export"));
        assert!(is_identifier("continue"));
    }
}
