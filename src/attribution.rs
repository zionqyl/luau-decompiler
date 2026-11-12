use crate::{execution, Error, Result};

pub const AUTHOR: &str = "@zionqyl";
pub const REPOSITORY: &str = "https://github.com/zionqyl/luau-decompiler";

pub fn block() -> String {
    format!(
        "--[=[\n    Luau Decompiler {}\n    Made by {AUTHOR}\n    {REPOSITORY}\n]=]",
        env!("CARGO_PKG_VERSION")
    )
}

pub fn prefix(strict: bool) -> String {
    format!("{}{}\n\n", if strict { "--!strict\n" } else { "" }, block())
}

pub fn is_official_comment(comment: &str) -> bool {
    if comment.len() > 512 {
        return false;
    }
    let Some(body) = comment
        .strip_prefix("--[=[")
        .and_then(|s| s.strip_suffix("]=]"))
    else {
        return false;
    };
    let mut lines = body.lines().map(str::trim).filter(|s| !s.is_empty());
    let Some(version) = lines
        .next()
        .and_then(|s| s.strip_prefix("Luau Decompiler "))
    else {
        return false;
    };
    !version.is_empty()
        && version.len() <= 64
        && version
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b".-+".contains(&b))
        && lines.next() == Some("Made by @zionqyl")
        && lines.next() == Some(REPOSITORY)
        && lines.next().is_none()
}

fn comment_end(source: &str, start: usize) -> usize {
    let bytes = source.as_bytes();
    let mut end = start + 2;
    if bytes.get(end) == Some(&b'[') {
        end += 1;
        while bytes.get(end) == Some(&b'=') {
            end += 1;
        }
        if bytes.get(end) == Some(&b'[') {
            let closing = format!("]{}]", "=".repeat(end - start - 3));
            return source[end + 1..]
                .find(&closing)
                .map_or(source.len(), |at| end + 1 + at + closing.len());
        }
    }
    source[start..]
        .find('\n')
        .map_or(source.len(), |at| start + at)
}

fn position(source: &str, offset: usize) -> (usize, usize) {
    let before = &source[..offset];
    let line = before.bytes().filter(|b| *b == b'\n').count() + 1;
    let column = before.rfind('\n').map_or(offset + 1, |at| offset - at);
    (line, column)
}

pub fn finalize(
    source: &mut String,
    regions: &mut [crate::types::GeneratedRegion],
    limit: usize,
) -> Result<()> {
    let mut cursor = usize::from(source.starts_with('\u{feff}')) * 3;
    let mut directives = Vec::new();
    let mut notices = Vec::new();
    loop {
        while source
            .as_bytes()
            .get(cursor)
            .is_some_and(u8::is_ascii_whitespace)
        {
            cursor += 1;
        }
        if source.as_bytes().get(cursor..cursor + 2) != Some(b"--") {
            break;
        }
        let end = comment_end(source, cursor);
        let comment = source[cursor..end].trim_end();
        if comment.starts_with("--!") && !comment.contains('\n') {
            directives.push(comment);
        } else if !is_official_comment(comment) {
            notices.push(comment);
        }
        cursor = end;
    }
    execution::charge_work(cursor.div_ceil(16).saturating_add(1))?;
    let mut leading = String::new();
    for directive in directives {
        leading.push_str(directive);
        leading.push('\n');
    }
    leading.push_str(&block());
    leading.push_str("\n\n");
    for notice in notices {
        leading.push_str(notice);
        leading.push_str("\n\n");
    }
    let body = if cursor == source.len() {
        "return\n"
    } else {
        &source[cursor..]
    };
    let size = leading
        .len()
        .checked_add(body.len())
        .filter(|n| *n <= limit)
        .ok_or_else(|| {
            Error::new(
                "limit",
                "finalized source including attribution exceeds max_output_bytes",
            )
        })?;
    if cursor < source.len() && source[..cursor] == leading {
        return Ok(());
    }
    let reservation = execution::output_buffer()?;
    reservation.reserve_capacity(size)?;
    let mut output = String::new();
    output
        .try_reserve_exact(size)
        .map_err(|e| Error::new("memory", e.to_string()))?;
    output.push_str(&leading);
    output.push_str(body);
    let (old_line, old_column) = position(source, cursor);
    let (new_line, new_column) = position(&leading, leading.len());
    for region in regions {
        for (line, column) in [
            (&mut region.first_line, &mut region.first_column),
            (&mut region.last_line, &mut region.last_column),
        ] {
            if *line > old_line {
                *line = new_line.saturating_add(*line - old_line);
            } else if *line == old_line && *column >= old_column {
                *line = new_line;
                *column = new_column.saturating_add(*column - old_column);
            }
        }
        if !region
            .transformations
            .iter()
            .any(|s| s == "canonical_attribution")
        {
            region.transformations.push("canonical_attribution".into());
        }
    }
    *source = output;
    Ok(())
}
