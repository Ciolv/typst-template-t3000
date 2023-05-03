// This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let t3000(
  // The paper's title.
  title: "Paper Title",

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,

  // The paper's content.
  body
) = {
  // Set document metdata.
  set document(title: title, author: authors.map(author => author.name))

  // Set the body font.
  set text(font: "STIX Two Text", size: 9.8pt)

  // Configure the page.
  set page(
    paper: "a4",
    margin: (x: 41.5pt, top: 75.51pt, bottom: 89.51pt),
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(9.8pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #set align(center)
      #set text( 12pt )
      #v(20pt, weak: true)
      *#it.body*
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #v(12pt, weak:true)
      #set par(first-line-indent: 0pt)
      *#it.body*
    ] else [
      // Third level headings are run-ins too, but different.
      _#(it.body):_
    ]
  })

  // Display the paper's title.
  v(3pt, weak: true)
  align(center, text(16pt, [*#title*]))
  v(8.35mm, weak: true)

  // Display the authors list.
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
        text(9pt, [*#author.name*])
        if "department" in author [
          \ #emph(author.department)
        ]
        if "organization" in author [
          \ #text(9pt, author.organization)
        ]
        if "location" in author [
          \ #author.location
        ]
        if "email" in author [
          \ #text(9pt, link("mailto:" + author.email))
        ]
      }))
    )

    if not is-last {
      v(16pt, weak: true)
    }
  }
  v(40pt, weak: true)

  // Start two column mode and configure paragraph properties.
  show: columns.with(2, gutter: 1cm)
  set par(justify: true, first-line-indent: 0em)
  show par: set block(spacing: 0.65em)

  // Display abstract and index terms.
  if abstract != none [
    #text(size: 9pt, 
    [
      #align(center, [*Abstract*])
      #block(inset: 1em, above: -2pt,abstract)
    ])

    #if index-terms != () [
      #h(1em)_Index terms_---#index-terms.join(", ")
    ]
    #v(2pt)
  ]

  // Display the paper's contents.
  body

  // Display bibliography.
  if bibliography-file != none {
    v(1em)
    show bibliography: set text(9pt)
    bibliography(bibliography-file, title: text(9.8pt)[Literatur], style: "chicago-author-date")
  }
}
