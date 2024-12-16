# Public Load Balancer
resource "oci_load_balancer_load_balancer" "FoggyKitchenPublicLoadBalancer" {
  shape          = var.lb_shape
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenPublicLoadBalancer"

  subnet_ids = [
    oci_core_subnet.FoggyKitchenLBSubnet.id
  ]

  dynamic "shape_details" {
    for_each = var.lb_shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  is_private = false  # Configuración pública del balanceador.
  freeform_tags = {
    Environment = "Production"
  }
}

# Load Balancer Backend Set
resource "oci_load_balancer_backendset" "FoggyKitchenPublicLoadBalancerBackendset" {
  name             = "FoggyKitchenPublicLBBackendset"
  load_balancer_id = oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    url_path            = "/"
    port                = 80
    interval_ms         = 10000
    timeout_in_millis   = 5000
    retries             = 3
    return_code         = 200
    response_body_regex = ".*"
    is_force_plain_text = true
  }

  session_persistence_configuration {
    cookie_name      = "LBSessionID"
    disable_fallback = false
  }
}

# Load Balancer Listener
resource "oci_load_balancer_listener" "FoggyKitchenPublicLoadBalancerListener" {
  name                     = "FoggyKitchenPublicListener"
  load_balancer_id         = oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.id
  protocol                 = "HTTP"
  port                     = 80
  default_backend_set_name = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name

  connection_configuration {
    idle_timeout_in_seconds = 300
  }
}

# Backend for WebServer1
resource "oci_load_balancer_backend" "FoggyKitchenPublicLoadBalancerBackend1" {
  load_balancer_id = oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.FoggyKitchenWebserver1.private_ip
  port             = 80
  weight           = 1
  backup           = false
  drain            = false
  offline          = false
}

# Backend for WebServer2
resource "oci_load_balancer_backend" "FoggyKitchenPublicLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.FoggyKitchenWebserver2.private_ip
  port             = 80
  weight           = 1
  backup           = false
  drain            = false
  offline          = false
}
