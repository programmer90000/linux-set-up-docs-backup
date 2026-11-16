#!/bin/bash

jq '.' Preferences > temp 
jq 'del(
  .brave_sync_v2.reset_devices_progress_token_time,
  .commerce_daily_metrics_last_update_time,
  .domain_diversity.last_reporting_timestamp,
  .domain_diversity.last_reporting_timestamp_v4,
  .extensions.settings.mhjfbmdgcfjbbpaeojofohoefgiehjai.first_install_time,
  .extensions.settings.mhjfbmdgcfjbbpaeojofohoefgiehjai.last_update_time,
  .extensions.settings.mnojpmjdmbbfmejpflffifhffcmidifd.first_install_time,
  .extensions.settings.mnojpmjdmbbfmejpflffifhffcmidifd.last_update_time,
  .gaia_cookie.periodic_report_time_2,
  .in_product_help.new_badge.ComposeNudge.feature_enabled_time,
  .in_product_help.new_badge.ComposeProactiveNudge.feature_enabled_time,
  .in_product_help.new_badge.CrossDeviceSigninFromDesktop.feature_enabled_time,
  .in_product_help.new_badge.GlicAppMenuNewBadge.feature_enabled_time,
  .in_product_help.new_badge.GlicContextMenu.feature_enabled_time,
  .in_product_help.new_badge.GlicKeyboardShortcutNewBadge.feature_enabled_time,
  .in_product_help.new_badge.ReadAnythingLineFocus.feature_enabled_time,
  .in_product_help.new_badge.SendTabToSelfEnhancedDesktopUI.feature_enabled_time,
  .in_product_help.new_badge.VerticalTabsNewBadge.feature_enabled_time,
  .in_product_help.recent_session_enabled_time,
  .in_product_help.recent_session_start_times,
  .in_product_help.session_last_active_time,
  .in_product_help.session_start_time,
  .profile.background_password_check.next_check_time,
  .profile.creation_time,
  .profile.last_engagement_time,
  .protection.macs.prefs.preference_reset_time,
  .protection.macs.prefs.preference_reset_time_encrypted_hash,
  .safebrowsing.event_timestamps,
  .safebrowsing.metrics_last_log_time,
  .sessions.event_log[0].time,
  .sessions.event_log[1].time
)' temp > temp2
rm temp
mv temp2 Preferences

jq '.' 'Local State' > temp && mv temp 'Local State'

jq '.' ~/.config/BraveSoftware/Brave-Browser/Default/Preferences > temp
jq 'del(
  .brave_sync_v2.reset_devices_progress_token_time,
  .commerce_daily_metrics_last_update_time,
  .domain_diversity.last_reporting_timestamp,
  .domain_diversity.last_reporting_timestamp_v4,
  .extensions.settings.mhjfbmdgcfjbbpaeojofohoefgiehjai.first_install_time,
  .extensions.settings.mhjfbmdgcfjbbpaeojofohoefgiehjai.last_update_time,
  .extensions.settings.mnojpmjdmbbfmejpflffifhffcmidifd.first_install_time,
  .extensions.settings.mnojpmjdmbbfmejpflffifhffcmidifd.last_update_time,
  .gaia_cookie.periodic_report_time_2,
  .in_product_help.new_badge.ComposeNudge.feature_enabled_time,
  .in_product_help.new_badge.ComposeProactiveNudge.feature_enabled_time,
  .in_product_help.new_badge.CrossDeviceSigninFromDesktop.feature_enabled_time,
  .in_product_help.new_badge.GlicAppMenuNewBadge.feature_enabled_time,
  .in_product_help.new_badge.GlicContextMenu.feature_enabled_time,
  .in_product_help.new_badge.GlicKeyboardShortcutNewBadge.feature_enabled_time,
  .in_product_help.new_badge.ReadAnythingLineFocus.feature_enabled_time,
  .in_product_help.new_badge.SendTabToSelfEnhancedDesktopUI.feature_enabled_time,
  .in_product_help.new_badge.VerticalTabsNewBadge.feature_enabled_time,
  .in_product_help.recent_session_enabled_time,
  .in_product_help.recent_session_start_times,
  .in_product_help.session_last_active_time,
  .in_product_help.session_start_time,
  .profile.background_password_check.next_check_time,
  .profile.creation_time,
  .profile.last_engagement_time,
  .protection.macs.prefs.preference_reset_time,
  .protection.macs.prefs.preference_reset_time_encrypted_hash,
  .safebrowsing.event_timestamps,
  .safebrowsing.metrics_last_log_time,
  .sessions.event_log[0].time,
  .sessions.event_log[1].time
)' temp > temp2
rm temp
mv temp2 ~/.config/BraveSoftware/Brave-Browser/Default/Preferences

jq '.' '/home/abdul/.config/BraveSoftware/Brave-Browser/Local State' > temp && mv temp '/home/abdul/.config/BraveSoftware/Brave-Browser/Local State'
