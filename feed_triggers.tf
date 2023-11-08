# TODO

# Create function suscriber targets to act according the action selected in the configuration.
# Do not create one function per action. A global function with TemporalAsset and Actions as an input.
# First trigger would be alert type: we create an alert and an associated notification channel with email. The cloud function would take the cloud asset an put into the log a dedicated entry that would trigger the alert, which in turns consume the notification channel.
