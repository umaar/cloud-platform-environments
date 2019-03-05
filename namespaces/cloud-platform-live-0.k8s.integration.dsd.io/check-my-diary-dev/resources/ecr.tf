terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "checkmydiary_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
  repo_name = "check-my-diary-dev"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary_ecr_credentials" {
  metadata {
    name      = "checkmydiary_ecr_credentials_output"
    namespace = "check-my-diary-dev"
  }

  data {
    access_key_id     = "${module.checkmydiary_ecr_credentials.access_key_id}"
    secret_access_key = "${module.checkmydiary_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.checkmydiary_ecr_credentials.repo_arn}"
    repo_url          = "${module.checkmydiary_ecr_credentials.repo_url}"
  }
}
