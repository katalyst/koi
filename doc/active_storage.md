# Active Storage in Koi

Koi 2.5 now supports using Active Storage for Image and Document uploads from CKEditor.
To use Active Storage, use the following setting in your Koi initializer:

    Koi::KoiAsset.storage_backend = :active_storage

Koi storage_backend will default to Dragonfly if Dragonfly::Model is defined, otherwise it will use Active Storage.

## Migrating from Dragonfly to Active Storage

To migrate from Dragonfly to Active Storage, Koi provides a migration rake task.
During the migrations, use storage_backend :dragonfly_active_storage to enable *both* Dragonfly and Active
Storage so that the rake tasks can copy data from one to the other.

### Add Active Storage to your application

- Run `rails active_storage:install` and run the migration. 
- Add `gem "image_processing"` to your Gemfile.
- Update `config/storage.yml`. If using S3, you may want to use a different bucket name for Active Storage, 
to separate Dragonfly assets from Active Storage.
- Optionally, add `config.active_storage.variant_processor = :vips` to config/application.rb to use libvips.

### Part 1: Models

This migration is used to convert Dragonfly accessors to Active Storage attachments.
Before starting, add equivalent Active Storage attachments to models which have Dragonfly_accessor.
For example, suppose you had a User model that defined a Dragonfly 'image' accessor:

    class User < ApplicationRecord
      Dragonfly_accessor :image
      has_one_attached :image_new # Add this line
    end

Now run the `koi:migrate:active_storage` rake task to convert the User image from a Dragonfly attachment
to an Active Storage attachment. The rake task accepts a "MODELS" environment variable which is a space separated
list specifying the conversions to be done, in the format "model_name:dragonfly_attribute:attachment_attribute", e.g.

    > rake koi:migrate:active_storage MODELS="User:image:image_new"

After the migration you can remove the Dragonfly_accessors, and optionally rename the Active Storage attachment
attribute to the same name as the Dragonfly accessor, e.g.

    ApplicationRecord.connection.execute <<~EOM
      UPDATE active_storage_attachments SET name='image' WHERE name='image_new' AND record_type='User'
    EOM

### Part 2: Attributes

This migration is used to update URLs in model attributes from Dragonfly URLs to Active Storage URLs.
For example, the Koi Page model has a 'description' attribute containing html that may have references to
Dragonfly media URLs. The URLs might look like this:

    /media/W1siZiIsIjIwMTcvMTEvMDEvMmxuZmR5NnhvdF9vbGl2ZXJpX256XzIwMTdfY29sbGVjdGlvbi5wZGYiXV0/document.pdf

Run the `koi:migrate:active_storage` rake task to convert Dragonfly media URLs in attributes
to Active Storage equivalents.
The rake task accepts an "ATTRIBUTES" environment variable which is a space separated list specifying
the conversions to be done, in the format "model_name:attribute". e.g.

    > rake koi:migrate:active_storage ATTRIBUTES="Page:description"

The way this rake task works for the above example is as follows:
1. For every Page record in the database, the description attribute is scanned for Dragonfly media urls.
2. For each Dragonfly media url found, the Dragonfly uid is extracted from the base64 encoded data.
3. Attempt to find a record for a model that defines a dragonfly_accessor with a matching uid. 
   For example, for the Koi Document model with a dragonfly_accessor :data, if a Document is found with
   data_uid equal to the extracted uid it will be used as a match.
4. If a match is found, the 'data_url' method of the matching record is called to construct a replacement url. The url
   method should accept an optional hash of attributes including 'size' which is a dragonfly thumbnail size. 
5. The url in the attribute is substituted from the result from step 4 and the record is saved.

### Migrations required for Koi 2.5

The following migrations are the minimum required to migrate a Koi application to Active Storage:

    > rake koi:migrate:active_storage MODELS="Image:data:attachment Document:data:attachment"
    > rake koi:migrate:active_storage ATTRIBUTES="Page:description ModuleNavItem:url"
