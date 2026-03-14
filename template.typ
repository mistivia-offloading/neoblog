#let doc-template(
    title: "TITLE",
    date: "1970-01-01",
    body: ""
) = [
    #show link: underline
    #show raw.where(block: true): block.with(
        inset: (left: 24pt, top: 0em, bottom: 0em),
        width: 100%
    )
    #show raw: set text(font: (
        "Courier Prime",
        "KingHwa_OldSong"
    ))
    #show raw.where(block: true): set text(
        size: 0.9em,
    )
    #set text(font: (
        "KingHwa_OldSong",
    ))
    #set heading(numbering: "1.")
    #set page(
        paper: "a5",
        number-align: center,
    )
    #set page(numbering: "1")
    #counter(page).update(1)
    #align(center, text(27pt)[
        *#title*
    ])
    #align(center, [#par(first-line-indent: 0em)[#date] #v(0.5em)])
    #set par(
        first-line-indent: 2em,
        justify: true,
        leading: 0.8em,
        spacing: 0.8em,
    )
    #set list(indent: 23pt)
    #set enum(indent: 23pt)
    #set terms(indent: 23pt)
    #show heading: it =>  {
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
        it
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
    }
    #show list: it => {
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
        it
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
    }
    #show raw.where(block: true): it => {
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
        it
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
    }
    #show image: it => { align(center)[ #it ] }
    #show image: it => {
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
        it
        par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
    }
    #body
]

#let myquote(body) = {
    par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
    pad(left: 2em, block(
        stroke: (left: 3pt + gray),
        inset: (left: 10pt, rest: 5pt),
        fill: luma(250),
    )[#body])
    par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
}
