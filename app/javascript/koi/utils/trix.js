import "trix";

// Trix does not provide an export
const Trix = window.Trix;

// Koi uses H4 for headings instead of H1
Trix.config.blockAttributes["heading4"] = {
  tagName: "h4",
  terminal: true,
  breakOnReturn: true,
  group: false,
};

// Remove H1 from trix list of acceptable tags
delete Trix.config.blockAttributes.heading1;

export default Trix;
