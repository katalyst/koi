import * as Lexxy from "lexxy";

Lexxy.configure({
  global: {
    authenticatedUploads: true,
  },
});

// The link toolbar's URL input is type=url, whose checkValidity() rejects
// schemeless values like #anchor and /relative that lexxy's link node happily
// preserves. Switch it to type=text with the same pattern Koi applies to the
// trix link dialog (see Koi::Tags::TrixToolbar::TRIX_DIALOGS_TEMPLATE) so both
// editors validate link input identically.
document.addEventListener("lexxy:initialize", ({ target }) => {
  target
    .querySelectorAll("lexxy-link-dropdown input[type=url]")
    .forEach((input) => {
      input.type = "text";
      input.pattern = "(https?|mailto:|tel:|/|#).*?";
    });
});

export default Lexxy;
