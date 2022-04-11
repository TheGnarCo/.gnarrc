# Rails 7 Install Instructions

This directory contains a rails configuration (`.railsrc`) and a [rails application template](https://guides.rubyonrails.org/rails_application_templates.html) to augment the behavior of `rails new`.

The resulting app will be pre-baked with all of our Gnarly wisdom.

To use:
 - download `.railsrc`
 - run `rails new app_name --rc=/path/to/.railsrc`

If you download `.railsrc` to your home directory, you will not need to include the `--rc` key, but keep in mind that *every* call to `rails new` will use this configuration.
