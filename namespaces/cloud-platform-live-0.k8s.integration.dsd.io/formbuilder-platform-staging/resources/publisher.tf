##################################################
# Publisher RDS

module "publisher-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=2.3"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "2"
  application                = "formbuilderpublisher"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "publisher-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-publisher-staging"
    namespace = "formbuilder-platform-staging"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.publisher-rds-instance.database_username}:${module.publisher-rds-instance.database_password}@${module.publisher-rds-instance.rds_instance_endpoint}/${module.publisher-rds-instance.database_name}"
  }
}

##################################################

########################################################
# Publisher Elasticache Redis (for resque + job logging)
module "publisher-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=2.0"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "formbuilderpublisher"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "publisher-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-publisher-staging"
    namespace = "formbuilder-platform-staging"
  }

  data {
    primary_endpoint_address = "${module.publisher-elasticache.primary_endpoint_address}"
    auth_token               = "${module.publisher-elasticache.auth_token}"
  }
}

########################################################

# Publisher ECR Repos
module "ecr-repo-fb-publisher-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-base"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-base" {
  metadata {
    name      = "ecr-repo-fb-publisher-base"
    namespace = "formbuilder-platform-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-base.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-base.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-base.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-web" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-web"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-web" {
  metadata {
    name      = "ecr-repo-fb-publisher-web"
    namespace = "formbuilder-platform-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-web.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-web.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-web.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-worker"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-worker" {
  metadata {
    name      = "ecr-repo-fb-publisher-worker"
    namespace = "formbuilder-platform-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-worker.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-worker.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-worker.secret_access_key}"
  }
}
