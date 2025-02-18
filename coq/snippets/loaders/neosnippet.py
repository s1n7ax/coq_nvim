from os import linesep
from os.path import splitext
from pathlib import Path
from string import whitespace
from textwrap import dedent
from typing import AbstractSet, MutableSequence, MutableSet, Sequence, Tuple

from ..types import ParsedSnippet
from .parse import raise_err

_COMMENT_START = "#"
_EXTENDS_START = "extends"
_INCLUDES_START = "include"
_SNIPPET_START = "snippet"
_ALIAS_START = "alias"
_LABEL_START = "abbr"
_OPTIONS_START = "options"
_IGNORED_STARTS = ("source", "delete", "regexp")
_SNIPPET_LINE_STARTS = {*whitespace}


def _start(line: str) -> Tuple[str, str, MutableSet[str]]:
    rest = line[len(_SNIPPET_START) :].strip()
    name, _, label = rest.partition(" ")
    if label.startswith('"') and label[1:].count('"') == 1:
        quoted, _, opts = label[1:].partition('"')
        options = {*opts.strip().split(" ")}
        return name, quoted, options
    else:
        return name, label, set()


def parse(path: Path) -> Tuple[AbstractSet[str], Sequence[ParsedSnippet]]:
    snippets: MutableSequence[ParsedSnippet] = []
    extends: MutableSet[str] = set()

    current_name = ""
    current_label: str = ""
    current_aliases: MutableSequence[str] = []
    current_options: MutableSet[str] = set()
    current_lines: MutableSequence[str] = []

    def push() -> None:
        if current_name:
            content = dedent(linesep.join(current_lines))
            snippet = ParsedSnippet(
                grammar="snu",
                content=content,
                label=current_label,
                doc="",
                matches={*current_aliases},
                options=current_options - {""},
            )
            snippets.append(snippet)

    lines = path.read_text().splitlines()
    for lineno, line in enumerate(lines, 1):
        if (
            not line
            or line.isspace()
            or line.startswith(_COMMENT_START)
            or any(line.startswith(i) for i in _IGNORED_STARTS)
        ):
            pass

        elif line.startswith(_EXTENDS_START):
            filetypes = line[len(_EXTENDS_START) :].strip()
            for filetype in filetypes.split(","):
                extends.add(filetype.strip())

        elif line.startswith(_INCLUDES_START):
            ft = line[len(_INCLUDES_START) :].strip()
            filetype, _ = splitext(ft)
            extends.add(filetype)

        elif line.startswith(_SNIPPET_START):
            push()
            current_name, current_label, current_options = _start(line=line)
            current_lines.clear()
            current_aliases.clear()
            current_aliases.append(current_name)

        elif line.startswith(_ALIAS_START):
            current_aliases.append(line[len(_ALIAS_START) :].strip())

        elif line.startswith(_LABEL_START):
            current_label = line[len(_LABEL_START) :].strip()

        elif line.startswith(_OPTIONS_START):
            for opt in line[len(_OPTIONS_START) :].strip().split(","):
                current_options.add(opt)

        elif any(line.startswith(c) for c in _SNIPPET_LINE_STARTS):
            if current_name:
                current_lines.append(line)
            else:
                reason = "Expected snippet name"
                raise_err(path, lineno=lineno, line=line, reason=reason)

        else:
            reason = "Unexpected line start"
            raise_err(path, lineno=lineno, line=line, reason=reason)

    push()

    return extends, snippets
