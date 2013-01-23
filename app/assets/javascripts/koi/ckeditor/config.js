/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function (config)
{
	// %REMOVE_START%
	
	// The configuration options below are needed when running CKEditor from source files.
	config.plugins = 'basicstyles,dialogui,dialog,clipboard,button,toolbar,list,indent,enterkey,entities,wysiwygarea,fakeobjects,link,pastetext,undo,pastefromword,autogrow,popup,filebrowser,panel,floatpanel,listblock,richcombo,format,image,oembed,showblocks,showborders,sourcearea,tab,table,menu,contextmenu,tabletools,tableresize';
	config.skin    = 'moono';
	
	// %REMOVE_END%

	// For the complete reference of configuration changes available see: http://docs.ckeditor.com/#!/api/CKEDITOR.config.

	config.autoGrow_onStartup    = true;
	config.forcePasteAsPlainText = true;

	config.toolbar = 'Custom';
	 
	config.toolbar_Custom =
	[
		{ name: 'document'    , items : [ 'Source', 'ShowBlocks'                                           ] },
		{ name: 'paste'       , items : [ 'Paste', 'PasteText', 'PasteFromWord'                            ] },
		{ name: 'format'      , items : [ 'Format', '-', 'NumberedList', 'BulletedList', '-', 'Blockquote' ] },
		{ name: 'paragraph'   , items : [ 'Outdent', 'Indent'                                              ] },
		{ name: 'alignment'   , items : [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight'                   ] },
		{ name: 'styles'      , items : [ 'Bold', 'Italic'                                                 ] },
		{ name: 'insert'      , items : [ 'Unlink', 'Link', 'Image', 'oembed','Table'                      ] }
	];

	config.format_tags = 'h1;h2;h3;h4;h5;h6;p';

	CKEDITOR.on ('dialogDefinition', function (event)
	{
		var data = event.data, name = data.name, definition = data.definition;

		// Add "devtools" to config.plugins above to determine UI component identifiers.
		// Details including IDs will be displayed for each component on hover.

		switch (name)
		{
			case 'link':
			var info   = definition.getContents ('info')
			var target = definition.getContents ('target')

			if (target && ! info.get ('linkTargetType')) info.add (target.get ('linkTargetType'))

			for (var id in { upload:1, target:1, advanced:1 }) definition.removeContents (id)
			break;

			case 'image':
			var info = definition.getContents ('info')
			
			for (var id in { txtWidth:1, txtHeight:1, txtBorder:1, txtHSpace:1, txtVSpace:1, ratioLock:1 }) info.remove (id)
			for (var id in { Upload:1, advanced:1 }) definition.removeContents (id)
			break;
		}
	});
};