!function ($) {

  $.fn.koiEditor = function () {

    this.ckeditor ({
      language: 'en',

      // height: '400px',
      // width: '650px',

      filebrowserBrowseUrl: '/admin/documents',
      filebrowserUploadUrl: '/admin/documents',

      filebrowserImageBrowseUrl: '/admin/images',
      filebrowserImageUploadUrl: '/admin/images',

      filebrowserWindowWidth: 950, // 930,
      filebrowserWindowHeight: 780, // 684,

      toolbar: [
        ['Source'],
        ['PasteText'],
        ['Undo', 'Redo'],
        ['Format'],
        ['Bold','Italic', 'Strike'],
        ['NumberedList', 'BulletedList'],
        ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
        ['Link', 'Unlink'],
        ['Image','Table', 'HorizontalRule', 'SpecialChar']
      ]
    });
  }

} (jQuery);
