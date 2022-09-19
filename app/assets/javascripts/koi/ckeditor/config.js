/**
 * @license Copyright (c) 2003-2022, CKSource Holding sp. z o.o. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function( config ) {
	config.extraPlugins 								 = 'showblocks';

 	config.filebrowserBrowseUrl          = '/admin/documents/new';
  config.filebrowserUploadUrl          = '/admin/uploads?asset_type=Document';
  config.filebrowserImageBrowseUrl     = '/admin/images/new';
  config.filebrowserImageUploadUrl     = '/admin/uploads?asset_type=Image';
  config.filebrowserImageBrowseLinkUrl = '/admin/documents/new';
  config.filebrowserImageUploadLinkUrl = '/admin/documents/new';
  
  config.filebrowserWindowWidth        = 950;
  config.filebrowserWindowHeight       = 750;
	config.autoGrow_onStartup    				 = true;
	config.forcePasteAsPlainText 				 = true;
	config.allowedContent        				 = true;

  // Koi Toolbar settings
  config.toolbarGroups = [
    {name:"document", groups:["mode","document","doctools" ]},
    {name:"clipboard", groups:["clipboard","undo"]},
    {name:"editing", groups:["find","selection"]},
    {name:"tools"},
    "/",
    {name:"styles"},
    {name:"basicstyles", groups:["basicstyles","cleanup"]},
    {name:"paragraph", groups:["list","indent","blocks","align"]},
    {name:"links"},
    {name:"insert"}
  ]

	// Remove some buttons, provided by the standard plugins, which we don't
	// need to have in the koi toolbar
	config.removeButtons = 'Templates,CopyFormatting,Blockquote,CreateDiv,Language,Styles,Underline,Subscript,Superscript,Strike,Anchor,HorizontalRule,SpecialChar,JustifyBlock,FontSize,Save,Print,Preview,NewPage,Font,Iframe,PageBreak,Smiley,Flash,About';

	// Set the most common block elements.
	config.format_tags = 'h2;h3;h4;h5;h6;p';

	// Make dialogs simpler.
	config.removeDialogTabs = 'image:advanced;document:advanced;link:advanced';
};
