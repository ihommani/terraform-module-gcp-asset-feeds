/**
 * Feeds allow to monitor asset type changes by designing a pubsub target topic and suscribing to it.
 * Specfic permissions to create feeds:
 * To check permissions required for this RPC   : https://cloud.google.com/asset-inventory/docs/access-control#required_permissions
 * To get a valid organization id               : https://cloud.google.com/asset-inventory/docs/access-control#required_permissions
 * To get a valid folder or project id          : https://cloud.google.com/resource-manager/docs/creating-managing-folders#viewing_or_listing_folders_and_projects
 *
 * More info:
 * https://cloud.google.com/asset-inventory/docs/monitoring-asset-changes
 *
 * Number limitation to take into account for feed creations:
 * https://cloud.google.com/asset-inventory/docs/monitoring-asset-changes#creating_feeds
 */

locals {
  feed_content_type = "RESOURCE"

  feeds_topic_config = {
    for k, v in var.feeds : k => {
      topic_name = lower("${v.assets_parent_type}-${v.assets_parent_id}-${v.trigger_action.type}-${k}-feed")
    }
  }
}


resource "google_pubsub_topic" "feeds" {
  for_each = local.feeds_topic_config

  project = var.hosting_project_id
  name    = each.value.topic_name
  labels = {
    description = try(lower(replace(var.feeds[each.key].description, " ", "-")), "N/A")
  }

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

locals {
  organisation_feeds_config = { for k, v in var.feeds : k => v if v.assets_parent_type == local.parent_node_types[0] }
  folder_feeds_config       = { for k, v in var.feeds : k => v if v.assets_parent_type == local.parent_node_types[1] }
  project_feeds_config      = { for k, v in var.feeds : k => v if v.assets_parent_type == local.parent_node_types[2] }
}

resource "google_cloud_asset_organization_feed" "organisation_feeds" {

  for_each = local.organisation_feeds_config

  billing_project = var.hosting_project_id
  org_id          = lower("${each.value.assets_parent_type}/${each.value.assets_parent_id}")
  feed_id         = lower("${each.value.assets_parent_type}-${each.value.assets_parent_id}-${each.key}-${each.value.trigger_action.type}")
  content_type    = local.feed_content_type
  asset_types     = [each.value.asset_type]

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.feeds[each.key].id
    }
  }
}

resource "google_cloud_asset_folder_feed" "folder_feeds" {

  for_each = local.folder_feeds_config

  billing_project = var.hosting_project_id
  folder          = lower("${each.value.assets_parent_type}/${each.value.assets_parent_id}")
  feed_id         = lower("${each.value.assets_parent_type}-${each.value.assets_parent_id}-${each.key}-${each.value.trigger_action.type}")
  content_type    = local.feed_content_type
  asset_types     = [each.value.asset_type]

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.feeds[each.key].id
    }
  }
}

resource "google_cloud_asset_project_feed" "project_feeds" {

  for_each = local.project_feeds_config

  billing_project = var.hosting_project_id
  project         = each.value.assets_parent_id
  feed_id         = lower("${each.value.assets_parent_type}-${each.value.assets_parent_id}-${each.key}-${each.value.trigger_action.type}")
  content_type    = local.feed_content_type
  asset_types     = [each.value.asset_type]

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.feeds[each.key].id
    }
  }
}
