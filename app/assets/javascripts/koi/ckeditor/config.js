/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	config.extraPlugins 								 = 'oembed,showblocks';

 	config.filebrowserBrowseUrl          = '/admin/documents';
  config.filebrowserUploadUrl          = '/admin/documents';
  config.filebrowserImageBrowseUrl     = '/admin/images';
  config.filebrowserImageUploadUrl     = '/admin/images';
  config.filebrowserImageBrowseLinkUrl = '/admin/documents';
  config.filebrowserImageUploadLinkUrl = '/admin/documents';
  config.filebrowserWindowWidth        = 950;
  config.filebrowserWindowHeight       = 750;

	config.autoGrow_onStartup    				 = true;
	config.forcePasteAsPlainText 				 = true;
	config.allowedContent        				 = true;

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'document',	   groups: [ 'mode', 'document', 'showblocks' ] },
		{ name: 'clipboard',   groups: [ 'clipboard' ] },
		{ name: 'styles' },
		{ name: 'list' },
		{ name: 'indent' },
		{ name: 'basicstyles', groups: [ 'basicstyles' ] },
		{ name: 'links',       groups: [ 'links', 'insert', 'oembed' ] },
	];

	// Remove some buttons, provided by the standard plugins, which we don't
	// need to have in the Standard(s) toolbar.
	config.removeButtons = 'Cut,Copy,Styles,Underline,Subscript,Superscript,Strike,Anchor,HorizontalRule,SpecialChar,Save,Print,Preview,NewPage,Font,Iframe,PageBreak,Smiley';

	// Se the most common block elements.
	config.format_tags = 'h2;h3;h4;h5;h6;p';

	// Make dialogs simpler.
	config.removeDialogTabs = 'image:advanced;link:advanced,document:advanced;link:advanced';
};
