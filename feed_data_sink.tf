/**
 * Each created feeds will generate on specific asset's change a TemporalAsset through a pub/sub topic.
 * Datasink represents the datastore that will receives those TemporalAssets and store them vanilla for
 * later investigation or any dashboarding purposes.
 * To do so, we create a BigQuery pub/sub subscription to each feed topics. BigQuery table being our datasink.
 *
 * More info:
 * https://cloud.google.com/asset-inventory/docs/monitoring-asset-changes
 * https://cloud.google.com/asset-inventory/docs/reference/rpc/google.cloud.asset.v1#temporalasset
 * https://cloud.google.com/pubsub/docs/bigquery
 */


data "google_project" "project" {
  project_id = var.hosting_project_id
}

locals {
  feed_data_sink_name            = "feeds_audit_log"
  feed_data_sink_name_table_name = "feeds_event_collection"

  pub_sub_managed_sa = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"

  table_id_elements = split("/", google_bigquery_table.data_sink_table.id)
}

resource "google_pubsub_topic" "dead_letter" {
  name = "feed-event-log-dead-letter"

  project = var.hosting_project_id

  depends_on = [ google_project_service.project_services ]
}

resource "google_pubsub_subscription" "feed_events_writer" {

  for_each = local.feeds_topic_config

  project = var.hosting_project_id
  name    = "${each.value.topic_name}-event-writer"
  topic   = google_pubsub_topic.feeds[each.key].id

  # https://cloud.google.com/pubsub/docs/bigquery
  bigquery_config {
    table          = "${local.table_id_elements[1]}.${local.table_id_elements[3]}.${local.table_id_elements[5]}"
    write_metadata = true
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 10
  }

  depends_on = [google_project_iam_member.data_sink_editor, ]
}

resource "google_project_iam_member" "data_sink_editor" {
  project = var.hosting_project_id
  role    = "roles/bigquery.dataEditor"
  member  = local.pub_sub_managed_sa
}

locals {
  group_operators = [for v in var.feed_operators : v if startswith(v, "group:")]
  user_operators  = [for v in var.feed_operators : v if startswith(v, "user:")]
  sa_operators    = [for v in var.feed_operators : v if startswith(v, "serviceAccount:")]
}

resource "google_bigquery_dataset" "data_sink" {

  project       = var.hosting_project_id
  dataset_id    = local.feed_data_sink_name
  friendly_name = local.feed_data_sink_name
  description   = "Stored filtered feed events related payloads and metadata"
  labels        = var.labels
  location      = var.region

  delete_contents_on_destroy = false

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  dynamic "access" {
    for_each = local.group_operators
    content {
      role           = "READER"
      group_by_email = replace(access.value, "group:", "")
    }
  }

  dynamic "access" {
    for_each = local.user_operators
    content {
      role          = "READER"
      user_by_email = replace(access.value, "user:", "")
    }
  }

  dynamic "access" {
    for_each = local.sa_operators
    content {
      role          = "READER"
      user_by_email = replace(access.value, "serviceAccount:", "")
    }
  }

  depends_on = [ google_project_service.project_services ]
}

resource "google_bigquery_table" "data_sink_table" {
  project    = var.hosting_project_id
  dataset_id = split("datasets/", google_bigquery_dataset.data_sink.id)[1]
  table_id   = local.feed_data_sink_name_table_name
  #require_partition_filter = true

  deletion_protection = false

  time_partitioning {
    type = "DAY"
  }

  # data will contain https://cloud.google.com/asset-inventory/docs/reference/rest/v1/TopLevel/batchGetAssetsHistory#temporalasset
  schema = <<EOF
[

  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  },
  {
    "name": "subscription_name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "pub/sub origin subscription"
  },
  {
    "name": "message_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "pub/sub message unique id"
  },
  {
    "name": "publish_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "pub/sub message timestamp"
  },
  {
    "name": "attributes",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "??"
  }

]
EOF
}
