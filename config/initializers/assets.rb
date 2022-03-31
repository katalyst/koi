# frozen_string_literal: true

require "non-digest-assets"

# CKEditor 4 includes internal relative references to assets at runtime.
# This gem allows Rails to serve those assets without requiring a sprockets digest.
NonDigestAssets.asset_selectors += [/koi\/ckeditor/]
