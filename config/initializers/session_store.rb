# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_iabin-mash_session',
  :secret      => '9ad798f7560a0d641b171bf1c5ef60fe2129fa19fdf500557584a2d7bf0516266f980840bad12be2f4f1d5f4604a66796a274a1b1b0b0129ec32f82fae3f02fe'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
