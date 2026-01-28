#let doc-template(
    title: "TITLE",
    date: "1970-01-01",
    body: ""
) = [
    #show link: underline
    #show raw.where(block: true): block.with(
        // fill: luma(240),
        inset: (left: 2.5em, top: 1em, bottom: 1em),
        width: 100%
    )
    #show raw: set text(font: (
        "Sarasa Mono SC"
    ))
    #set text(font: (
        "Libertinus Serif",
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
    #set list(indent: 2em)
    #set enum(indent: 2em)
    #set terms(indent: 2em)
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