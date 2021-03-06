#####################################################################
# ENABLE KUBERNETES API
#####################################################################

resource "google_project_service" "gke" {
  project = "${var.project}"
  service = "container.googleapis.com"
  disable_on_destroy = false
  disable_dependent_services = false
}

#####################################################################
# GKE Cluster
#####################################################################
resource "google_container_cluster" "guestbook" {
  name               = "${var.cluster_name}"
  depends_on         = ["google_project_service.gke"]
  zone               = "${var.region}-b"
  initial_node_count = "${var.cluster_initial_node_count}"

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
    ]
  }
}

#####################################################################
# Output for K8S
#####################################################################
output "client_certificate" {
  value     = "${google_container_cluster.guestbook.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.guestbook.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.guestbook.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.guestbook.endpoint}"
  sensitive = true
}
