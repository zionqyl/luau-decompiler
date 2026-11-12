use std::{fs, path::Path};

fn quoted(bytes: &[u8], start: usize, quote: u8) -> usize {
    let mut index = start + 1;
    while index < bytes.len() {
        if bytes[index] == b'\\' {
            index = (index + 2).min(bytes.len());
        } else if bytes[index] == quote {
            return index + 1;
        } else {
            index += 1;
        }
    }
    bytes.len()
}

fn long_luau(bytes: &[u8], start: usize) -> Option<usize> {
    if bytes.get(start) != Some(&b'[') {
        return None;
    }
    let mut end = start + 1;
    while bytes.get(end) == Some(&b'=') {
        end += 1;
    }
    if bytes.get(end) != Some(&b'[') {
        return None;
    }
    let delimiter = &bytes[start..=end];
    let mut index = end + 1;
    while index + delimiter.len() <= bytes.len() {
        if bytes[index] == b']'
            && bytes[index + delimiter.len() - 1] == b']'
            && bytes[index + 1..index + delimiter.len() - 1]
                .iter()
                .all(|b| *b == b'=')
        {
            return Some(index + delimiter.len());
        }
        index += 1;
    }
    Some(bytes.len())
}

fn raw_rust(bytes: &[u8], start: usize) -> Option<usize> {
    if bytes.get(start) != Some(&b'r') {
        return None;
    }
    let mut end = start + 1;
    while bytes.get(end) == Some(&b'#') {
        end += 1;
    }
    if bytes.get(end) != Some(&b'"') {
        return None;
    }
    let hashes = end - start - 1;
    let mut index = end + 1;
    while index < bytes.len() {
        if bytes[index] == b'"'
            && bytes
                .get(index + 1..index + 1 + hashes)
                .is_some_and(|tail| tail.iter().all(|b| *b == b'#'))
        {
            return Some(index + 1 + hashes);
        }
        index += 1;
    }
    Some(bytes.len())
}

fn raw_cpp(bytes: &[u8], start: usize) -> Option<usize> {
    if bytes.get(start..start + 2) != Some(b"R\"") {
        return None;
    }
    let delimiter_end = bytes.get(start + 2..)?.iter().position(|b| *b == b'(')? + start + 2;
    if delimiter_end - start > 18 {
        return None;
    }
    let delimiter = &bytes[start + 2..delimiter_end];
    let mut index = delimiter_end + 1;
    while index < bytes.len() {
        if bytes[index] == b')'
            && bytes.get(index + 1..index + 1 + delimiter.len()) == Some(delimiter)
            && bytes.get(index + 1 + delimiter.len()) == Some(&b'"')
        {
            return Some(index + delimiter.len() + 2);
        }
        index += 1;
    }
    Some(bytes.len())
}

fn ranges(source: &str, luau: bool) -> Vec<(usize, usize)> {
    let bytes = source.as_bytes();
    let mut found = Vec::new();
    let mut index = 0;
    while index < bytes.len() {
        let start = index;
        if luau {
            if let Some(end) = long_luau(bytes, index) {
                index = end;
                continue;
            }
        } else if let Some(end) = raw_rust(bytes, index).or_else(|| raw_cpp(bytes, index)) {
            index = end;
            continue;
        }
        if bytes[index] == b'"' || (luau && (bytes[index] == b'\'' || bytes[index] == b'`')) {
            index = quoted(bytes, index, bytes[index]);
            continue;
        }
        if !luau && bytes[index] == b'\'' {
            let end = quoted(bytes, index, b'\'');
            if end <= index + 12 && !bytes[index + 1..end].contains(&b'\n') {
                index = end;
                continue;
            }
        }
        let mut comment = false;
        if luau && bytes.get(index..index + 2) == Some(b"--") {
            comment = true;
            index = long_luau(bytes, index + 2).unwrap_or_else(|| {
                bytes[index..]
                    .iter()
                    .position(|b| *b == b'\n')
                    .map_or(bytes.len(), |end| index + end)
            });
        } else if !luau && bytes.get(index..index + 2) == Some(b"//") {
            comment = true;
            index = bytes[index..]
                .iter()
                .position(|b| *b == b'\n')
                .map_or(bytes.len(), |end| index + end);
        } else if !luau && bytes.get(index..index + 2) == Some(b"/*") {
            comment = true;
            index += 2;
            let mut depth = 1;
            while index < bytes.len() && depth > 0 {
                if bytes.get(index..index + 2) == Some(b"/*") {
                    depth += 1;
                    index += 2;
                } else if bytes.get(index..index + 2) == Some(b"*/") {
                    depth -= 1;
                    index += 2;
                } else {
                    index += 1;
                }
            }
        }
        if comment {
            let text = &source[start..index];
            if !text.starts_with("--!")
                && !(luau && luau_decompiler::attribution::is_official_comment(text))
                && !text.contains("SPDX-License-Identifier")
                && !text.to_ascii_lowercase().contains("copyright")
            {
                found.push((start, index));
            }
        } else {
            index += 1;
        }
    }
    found
}

fn run() -> Result<(), String> {
    let mut args = std::env::args().skip(1);
    let write = args.next().ok_or("expected --check or --write")?;
    if write != "--check" && write != "--write" {
        return Err("expected --check or --write".into());
    }
    let mut failed = false;
    for path in args {
        let source = fs::read_to_string(&path).map_err(|e| e.to_string())?;
        let luau = matches!(
            Path::new(&path).extension().and_then(|e| e.to_str()),
            Some("luau" | "lua")
        );
        let comments = ranges(&source, luau);
        if comments.is_empty() {
            continue;
        }
        if write == "--check" {
            eprintln!("{path}: {} explanatory comments", comments.len());
            failed = true;
        } else {
            let mut output = source.into_bytes();
            for (start, end) in comments {
                for byte in &mut output[start..end] {
                    if !matches!(*byte, b'\n' | b'\r') {
                        *byte = b' ';
                    }
                }
            }
            let output = String::from_utf8(output).map_err(|e| e.to_string())?;
            let trimmed = output
                .lines()
                .map(str::trim_end)
                .collect::<Vec<_>>()
                .join("\n")
                + "\n";
            fs::write(path, trimmed).map_err(|e| e.to_string())?;
        }
    }
    if failed {
        Err("first-party code contains explanatory comments".into())
    } else {
        Ok(())
    }
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn strings_directives_and_fixture_data_remain_untouched() {
        let rust = "let a = r###\"// fixture /* text */\"###; let b = \"// string\"; let c = '//'; // remove\n/* outer /* nested */ end */";
        let comments = ranges(rust, false);
        assert_eq!(comments.len(), 2);
        assert_eq!(&rust[comments[0].0..comments[0].1], "// remove");
        let lua = "--!strict\nlocal a = [==[-- preserved]==]; local b = '-- literal' -- remove\n--[=[remove]=]";
        let comments = ranges(lua, true);
        assert_eq!(comments.len(), 2);
        assert_eq!(&lua[comments[0].0..comments[0].1], "-- remove");
        assert!(ranges("R\"tag(// preserved)tag\"", false).is_empty());
    }
}
