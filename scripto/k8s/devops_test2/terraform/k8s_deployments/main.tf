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

resource "kubernetes_config_map" "scala-app-env" {
  metadata {
    name = "scala-app-env"
  }

  data = {
    CASSANDRA_HOST = "cassandra.default.svc.cluster.local"
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
  provisioner "local-exec" {
      command = "echo sleep 60s to let cassandra initialise; sleep 60"
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




resource "kubernetes_job" "cassandra-create-schema" {
  metadata {
    name = "cassandra-create-schema"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "cassandra-create-schema"
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
    backoff_limit = 6
  }
  depends_on = [kubernetes_deployment.cassandra]
}


resource "kubernetes_job" "cassandra-insert-data" {
  metadata {
    name = "cassandra-insert-data"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "cassandra-insert-data"
          image   = "cassandra:3.11.4"
          command = ["cqlsh", "-f", "/opt/cassandra-cql/insert-data.cql", "cassandra.default.svc.cluster.local"]
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
    backoff_limit = 6
  }
  depends_on = [kubernetes_job.cassandra-create-schema]
}




resource "kubernetes_deployment" "scala-app" {
  metadata {
    name = "scala-app"
    labels = {
      test = "scala-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "scala-app"
      }
    }

    template {
      metadata {
        labels = {
          test = "scala-app"
        }
      }

      spec {
        container {
          image = "gcr.io/remi-test-241607/scala-app:latest"
          name  = "scala-app"
          image_pull_policy = "Always"
          port {
            container_port = 9000
          }
          env_from {
            config_map_ref {
              name = "scala-app-env"
            }
          }
        }


      }
    }
  }
  depends_on = [kubernetes_job.cassandra-insert-data]
}

