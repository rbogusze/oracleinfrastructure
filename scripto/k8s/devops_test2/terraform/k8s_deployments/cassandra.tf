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



        }
      }
    }
  }
}
