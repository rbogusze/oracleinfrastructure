provider "google" {
  project = "remi-test-241607"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_container_cluster" "remi-test" {
  name               = "remi-test"
  network            = "default"
  location           = "us-central1-a"
  initial_node_count = 3
}
