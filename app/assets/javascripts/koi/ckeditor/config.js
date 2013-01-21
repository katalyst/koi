/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	
	// %REMOVE_START%
	// The configuration options below are needed when running CKEditor from source files.
	config.plugins = 'basicstyles,dialogui,dialog,clipboard,button,toolbar,list,indent,enterkey,entities,wysiwygarea,fakeobjects,link,pastetext,undo,table,panel,floatpanel,menu,contextmenu,tabletools,tableresize,tab,sourcearea,showborders,showblocks,removeformat,image,horizontalrule,listblock,richcombo,format,blockquote,autogrow,oembed,popup,filebrowser';
	config.skin = 'moono';
	// %REMOVE_END%

	config.autoGrow_onStartup = true;

	// Define changes to default configuration here.
	// For the complete reference:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	config.toolbar = 'Custom';
	 
	config.toolbar_Custom =
	[
		{ name: 'document'    , items : [ 'Source', 'ShowBlocks'                                           ] },
		{ name: 'format'      , items : [ 'Format', '-', 'NumberedList', 'BulletedList', '-', 'Blockquote' ] },
		{ name: 'paragraph'   , items : [ 'Outdent', 'Indent'                                              ] },
		{ name: 'alignment'   , items : [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight'                   ] },
		{ name: 'styles'      , items : [ 'Bold', 'Italic', 'Underline', '-', 'RemoveFormat'               ] },
		{ name: 'links'       , items : [ 'Link', 'Unlink'                                                 ] },
		{ name: 'insert'      , items : [ 'Image','oembed','Table','HorizontalRule'                         ] }
	];

	// Considering that the basic setup doesn't provide pasting cleanup features,
	// it's recommended to force everything to be plain text.
	config.forcePasteAsPlainText = true;

	// Let's have it basic on dialogs as well.
	config.removeDialogTabs = 'link:upload;link:target;link:advanced;image:Upload;image:advanced'
};
