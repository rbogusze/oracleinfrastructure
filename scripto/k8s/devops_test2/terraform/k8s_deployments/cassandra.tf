resource "kubernetes_persistent_volume_claim" "pd-cassandra-volume-claim" {
  metadata {
    name = "pd-cassandra-volume-claim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}


resource "kubernetes_config_map" "cassandra-cql" {
  metadata {
    name = "cassandra-cql"
  }

  data = {
    "create-schema.cql" = "${file("${path.module}/create-schema.cql")}"
    "insert-data.cql" = "${file("${path.module}/insert-data.cql")}"
    "query-data.cql" = "${file("${path.module}/query-data.cql")}"
  }

}



resource "kubernetes_deployment" "cassandra" {
  metadata {
    name = "cassandra"
    labels = {
      test = "cassandra"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "cassandra"
      }
    }

    template {
      metadata {
        labels = {
          test = "cassandra"
        }
      }

      spec {
        container {
          image = "cassandra:3.11.4"
          name  = "cassandra"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9042
          }
          volume_mount {
            name = "pd-cassandra-volume"
            mount_path = "/var/lib/cassandra"
          }
          volume_mount {
            name = "cassandra-cql"
            mount_path = "/opt/cassandra-cql"
          }
        }

        volume {
          name = "pd-cassandra-volume"
          persistent_volume_claim {
            claim_name = "pd-cassandra-volume-claim"
          }
        }
        volume {
          name = "cassandra-cql"
          config_map {
            name = "cassandra-cql"
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "cassandra" {
  metadata {
    name = "cassandra"
  }
  spec {
    selector = {
      test = "cassandra"
    }
    port {
      port        = 9042
      target_port = 9042
    }

    type = "ClusterIP"
  }
}




resource "kubernetes_job" "demo" {
  metadata {
    name = "demo"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "pi"
          image   = "cassandra:3.11.4"
          command = ["cqlsh", "-f", "/opt/cassandra-cql/create-schema.cql", "cassandra.default.svc.cluster.local"]
          volume_mount {
            name = "cassandra-cql"
            mount_path = "/opt/cassandra-cql"
          }
        }
        volume {
          name = "cassandra-cql"
          config_map {
            name = "cassandra-cql"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
}
