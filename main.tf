
resource "google_project_service" "project" {
  project = google_project.iamproject.name
  count = length(var.gcp_service_list)  
  service = var.gcp_service_list[count.index]

  disable_dependent_services = true
}

resource "google_compute_network" "default" {
  name                    = var.network_name
  project                 = google_project.iamproject.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "west1" {
  name                     = var.subnetwork_name1
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.regionc1
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "clus1-pod"
    ip_cidr_range = "10.88.0.0/14"
  } 
  
  secondary_ip_range {
    range_name    = "clus1-svc"
    ip_cidr_range = "172.16.0.0/20"
  } 

}

resource "google_compute_subnetwork" "west4" {
  name                     = var.subnetwork_name2
  ip_cidr_range            = "10.126.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.regionc2
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "clus2-pod"
    ip_cidr_range = "10.92.0.0/14"
  } 
  
  secondary_ip_range {
    range_name    = "clus2-svc"
    ip_cidr_range = "172.16.16.0/20"
  } 

}

data "google_client_config" "current" {
}

data "google_container_engine_versions" "version1" {
  location = var.locationc1
}

data "google_container_engine_versions" "version2" {
  location = var.locationc2
}

resource "google_container_cluster" "cluster1" {
  name               = var.cluster_name1
  location           = var.locationc1
  initial_node_count = 1
  remove_default_node_pool = true
  min_master_version = data.google_container_engine_versions.version1.latest_master_version
  network            = google_compute_network.default.name
  subnetwork         = google_compute_subnetwork.west1.name
  // networking_mode    = VPC_NATIVE

  // Use legacy ABAC until these issues are resolved:
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  ip_allocation_policy {
    cluster_secondary_range_name = google_compute_subnetwork.west1.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.west1.secondary_ip_range[1].range_name
  }

  // Wait for the GCE LB controller to cleanup the resources.
  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 90"
  }
}

resource "google_container_node_pool" "nodepool1" {
  name       = "nodepool1"
  location   = var.locationc1
  cluster    = google_container_cluster.cluster1.name
  node_count = 3

  node_config {
    machine_type = "e2-medium"
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 4
  }

  management {
    auto_repair   = true
    auto_upgrade   = true
  }
}

resource "google_container_cluster" "cluster2" {
  name               = var.cluster_name2
  location           = var.locationc2
  initial_node_count = 1
  remove_default_node_pool = true
  min_master_version = data.google_container_engine_versions.version2.latest_master_version
  network            = google_compute_network.default.name
  subnetwork         = google_compute_subnetwork.west4.name
  // networking_mode    = VPC_NATIVE

  // Use legacy ABAC until these issues are resolved:
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  ip_allocation_policy {
    cluster_secondary_range_name = google_compute_subnetwork.west4.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.west4.secondary_ip_range[1].range_name
  }

  // Wait for the GCE LB controller to cleanup the resources.
  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 90"
  }
}

resource "google_container_node_pool" "nodepool2" {
  name       = "nodepool2"
  location   = var.locationc2
  cluster    = google_container_cluster.cluster2.name
  node_count = 3

  node_config {
    machine_type = "e2-medium"
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 4
  }

  management {
    auto_repair   = true
    auto_upgrade   = true
  }
}

output "network" {
  value = google_compute_network.default.name
}

output "subnetwork_name1" {
  value = google_compute_subnetwork.west1.name
}

output "subnetwork_name2" {
  value = google_compute_subnetwork.west4.name
}

output "cluster_name1" {
  value = google_container_cluster.cluster1.name
}

output "cluster_name2" {
  value = google_container_cluster.cluster2.name
}

output "cluster_region1" {
  value = var.regionc1
}

output "cluster_region2" {
  value = var.regionc2
}

output "cluster_location1" {
  value = google_container_cluster.cluster1.location
}

output "cluster_location2" {
  value = google_container_cluster.cluster2.location
}
