provider "google" {
  billing_project       = "hld-int-sbxiho-prj-cloud-iho"
  user_project_override = true
}

module "basic_feed" {
  source             = "./.."
  hosting_project_id = "hld-int-sbxiho-prj-cloud-iho"
  feed_operators     = ["user:ismael.hommani.ext@lvmh.com", "user:renaud.buttiero.ext@lvmh.com"]

  feeds = {

    cf-crud = {
      description        = "Email alert on function CRUD operations"
      assets_parent_type = "PROJECTS"
      assets_parent_id   = "hld-int-sbxiho-prj-cloud-iho"
      asset_type         = "cloudfunctions.googleapis.com/Function"
      trigger_action = {
        type   = "ALERT"
        config = {}
      }
    }

    hld-int-cf-crud = {
      description        = "Email alert on function CRUD operations"
      assets_parent_type = "FOLDERS"
      assets_parent_id   = "77528958776"
      asset_type         = "cloudfunctions.googleapis.com/Function"
      trigger_action = {
        type   = "ALERT"
        config = {}
      }
    }
  }
}
