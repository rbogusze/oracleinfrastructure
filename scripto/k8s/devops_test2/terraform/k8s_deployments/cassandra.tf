resource "kubernetes_deployment" "cassandra" {
  metadata {
    name = "cassandra"
    labels = {
      test = "cassandra"
    }
  }

  spec {
    replicas = 3

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
