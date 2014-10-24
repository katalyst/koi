/**
 *
 * This file contains common variables used by Ornament.
 *
 */



// Links ending with these file extensions will be treated as external links.
//

Ornament.externalLinkExtensions = [
  "doc",
  "docx",
  "pdf",
  "ppt",
  "pptx",
  "xls",
  "xlsx"
];



// Elements matching these jQuery selectors won't be treated as external links.
//

Ornament.internalLinkSelectors = [

  "[rel*=internal]",
  // "[href^='http://example.com']",
  // "[href^='http://www.example.com']"

];


