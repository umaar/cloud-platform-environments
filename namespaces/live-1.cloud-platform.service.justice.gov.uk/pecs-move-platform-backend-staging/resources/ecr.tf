module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"

  team_name = "${var.team_name}"
  repo_name = "${var.repo_name}"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-pecs-move-platform-backend"
    namespace = "${var.namespace}"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}
