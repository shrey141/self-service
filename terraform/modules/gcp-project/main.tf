terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create the GCP Project
resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  labels = merge(
    var.labels,
    {
      managed_by  = "terraform"
      environment = var.environment
    }
  )

  auto_create_network = var.auto_create_network
}

# Enable required APIs
resource "google_project_service" "services" {
  for_each = toset(var.enabled_apis)

  project = google_project.project.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# Create a default service account if requested
resource "google_service_account" "default" {
  count = var.create_default_service_account ? 1 : 0

  project      = google_project.project.project_id
  account_id   = "${var.project_id}-sa"
  display_name = "Default Service Account for ${var.project_name}"
  description  = "Service account created by self-service platform"

  depends_on = [google_project_service.services]
}

# Grant basic roles to the service account
resource "google_project_iam_member" "service_account_roles" {
  for_each = var.create_default_service_account ? toset(var.service_account_roles) : toset([])

  project = google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.default[0].email}"

  depends_on = [google_service_account.default]
}

# Create VPC if requested
resource "google_compute_network" "vpc" {
  count = var.create_vpc ? 1 : 0

  project                 = google_project.project.project_id
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  description             = "VPC for ${var.project_name}"

  depends_on = [google_project_service.services]
}

# Create subnets
resource "google_compute_subnetwork" "subnets" {
  for_each = var.create_vpc ? var.subnets : {}

  project       = google_project.project.project_id
  name          = each.key
  region        = each.value.region
  network       = google_compute_network.vpc[0].id
  ip_cidr_range = each.value.ip_cidr_range

  private_ip_google_access = lookup(each.value, "private_ip_google_access", true)

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ip_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  depends_on = [google_compute_network.vpc]
}

# Create Cloud NAT if requested
resource "google_compute_router" "router" {
  count = var.create_vpc && var.create_nat ? 1 : 0

  project = google_project.project.project_id
  name    = "${var.project_id}-router"
  region  = var.default_region
  network = google_compute_network.vpc[0].id

  depends_on = [google_compute_network.vpc]
}

resource "google_compute_router_nat" "nat" {
  count = var.create_vpc && var.create_nat ? 1 : 0

  project = google_project.project.project_id
  name    = "${var.project_id}-nat"
  router  = google_compute_router.router[0].name
  region  = var.default_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [google_compute_router.router]
}
