export type HighlightToken = {
  text: string;
  kind?: "keyword" | "string" | "comment" | "number" | "type";
};
const keywords = new Set(
  "and break continue do else elseif end false for function if in local nil not or repeat return then true until while export type typeof".split(
    " ",
  ),
);
const types = new Set(
  "any unknown never number string boolean thread buffer vector self".split(" "),
);

export function highlight(source: string): HighlightToken[] {
  if (source.length > 512 * 1024) return [{ text: source }];
  const tokens: HighlightToken[] = [];
  let index = 0;
  let plain = 0;
  function emit(end: number, kind: HighlightToken["kind"]) {
    if (plain < index) tokens.push({ text: source.slice(plain, index) });
    tokens.push({ text: source.slice(index, end), kind });
    index = end;
    plain = end;
  }
  while (index < source.length && tokens.length < 20000) {
    const comment = source.startsWith("--", index);
    const longStart = index + (comment ? 2 : 0);
    const opening = source.slice(longStart, longStart + 258).match(/^\[(=*)\[/);
    if (opening) {
      const closing = "]" + opening[1] + "]";
      const end = source.indexOf(closing, longStart + opening[0].length);
      emit(end < 0 ? source.length : end + closing.length, comment ? "comment" : "string");
    } else if (comment) {
      const end = source.indexOf("\n", index);
      emit(end < 0 ? source.length : end, "comment");
    } else if (source[index] === '"' || source[index] === "'" || source[index] === "`") {
      const quote = source[index];
      let end = index + 1;
      while (end < source.length) {
        if (source[end] === "\\") end = Math.min(source.length, end + 2);
        else if (source[end++] === quote) break;
      }
      emit(end, "string");
    } else if (/[A-Za-z_]/.test(source[index])) {
      let end = index + 1;
      while (end < source.length && /[A-Za-z0-9_]/.test(source[end])) end++;
      const word = source.slice(index, end);
      if (keywords.has(word)) emit(end, "keyword");
      else if (types.has(word)) emit(end, "type");
      else index = end;
    } else if (/[0-9]/.test(source[index])) {
      const number = source
        .slice(index)
        .match(
          /^(?:0[xX][0-9a-fA-F_]+|0[bB][01_]+|\d[\d_]*(?:\.(?!\.)[\d_]*)?(?:[eE][+-]?[\d_]+)?)/,
        );
      if (number) emit(index + number[0].length, "number");
      else index++;
    } else index++;
  }
  if (plain < source.length) tokens.push({ text: source.slice(plain) });
  return tokens;
}
