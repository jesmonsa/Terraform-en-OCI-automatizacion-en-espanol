# Public Load Balancer
resource "oci_load_balancer" "FoggyKitchenPublicLoadBalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  subnet_ids     = [oci_core_subnet.FoggyKitchenLBSubnet.id]
  display_name   = "FoggyKitchenPublicLoadBalancer"
  is_private     = false

  freeform_tags = merge(
    local.common_tags,
    {
      role = "loadbalancer"
      type = "public"
    }
  )

  network_security_group_ids = []
}

# Load Balancer Backend Set
resource "oci_load_balancer_backendset" "FoggyKitchenPublicLoadBalancerBackendset" {
  name             = "FoggyKitchenPublicLBBackendset"
  load_balancer_id = oci_load_balancer.FoggyKitchenPublicLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    url_path            = "/health"
    port                = 80
    interval_ms         = var.health_check_interval_ms
    timeout_in_millis   = var.health_check_timeout_ms
    retries             = var.health_check_retries
    return_code         = 200
    response_body_regex = ".*OK.*"
  }

  session_persistence_configuration {
    cookie_name      = "FoggyKitchenLB"
    disable_fallback = true
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.lb_cert.certificate_name
    verify_peer_certificate = false
  }
}

# Load Balancer Listener
resource "oci_load_balancer_listener" "FoggyKitchenPublicLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.FoggyKitchenPublicLoadBalancer.id
  name                     = "FoggyKitchenPublicLoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = 300
  }

  rule_set_names = []
}

# Backend for WebServer1
resource "oci_load_balancer_backend" "FoggyKitchenPublicLoadBalancerBackend1" {
  load_balancer_id = oci_load_balancer.FoggyKitchenPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.FoggyKitchenWebserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Backend for WebServer2
resource "oci_load_balancer_backend" "FoggyKitchenPublicLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer.FoggyKitchenPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.FoggyKitchenWebserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
